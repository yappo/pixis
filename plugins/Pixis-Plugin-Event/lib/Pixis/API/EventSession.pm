
package Pixis::API::EventSession;
use Moose;

with 'Pixis::API::Base::DBIC';

before 'create_from_form' => sub {
    my ($self, $form) = @_;

    my $ok = $self->check_overlap( {
        event_id => $form->param('event_id'),
        track_id      => $form->param('track_id'),
        start_on      => $form->param('start_on'),
        end_on        => $form->param('end_on'),
    });
    if (! $ok) {
        confess "Selected timeslot conflicts with another session";
    }
};

__PACKAGE__->meta->make_immutable;

no Moose;

sub check_overlap {
    my ($self, $args) = @_;

    # Make sure that there are no overlapping sessions
    my $schema = Pixis::Registry->get(schema => 'master');
    my $start_on = $args->{start_on};
    my $end_on = $args->{end_on};
    $schema->resultset('EventSession')->search(
        {   
            event_id => $args->{event_id},
            track_id => $args->{track_id},
            -or => [
                -and => [
                    start_on => { '>=' => $start_on },
                    start_on => { '<' => $end_on },
                ],
                -and => [
                    end_on => { '>=' => $start_on },
                    end_on => { '<' => $end_on },
                ]
            ]
        }
    )->single ? 0 : 1;
}

sub load_from_track {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get(schema => 'master');
    my @ids = map { $_->id } $schema->resultset('EventSession')->search(
        {   
            event_id => $args->{event_id},
            track_id => $args->{track_id},
        },
        {
            select => [ qw(id) ]
        },
    );

    return $self->load_multi(@ids);
}

sub load_from_date {
    my ($self, $args) = @_;

    my @ids = map { $_->id } $self->resultset->search(
        {
            event_id => $args->{event_id},
            start_on => { -between => [ $args->{start_on}, $args->{start_on}->clone->add(days => 1) ] },
        },
        {
            select => [qw(id)],
            order_by => [ 'start_on' ],
        }
    );

    return $self->load_multi(@ids);
}

1;
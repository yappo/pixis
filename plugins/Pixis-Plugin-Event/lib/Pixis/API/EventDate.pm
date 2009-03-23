
package Pixis::API::EventDate;
use Moose;
use Pixis::API::Base::DBIC;
use namespace::clean -except => qw(meta);

with 'Pixis::API::Base::DBIC';

sub load_from_event {
    my ($self, $event_id) = @_;

    my @tracks = 
        map { $_->id }
        $self->resultset->search(
            { event_id => $event_id },
            { select => [ qw(id) ] }
        )
    ;

    return $self->load_multi(@tracks);
}

sub load_from_event_date {
    my ($self, $args) = @_;

    $self->resultset->search(
        {
            event_id => $args->{event_id},
            date     => $args->{date}
        }
    )->single;
}

__PACKAGE__->meta->make_immutable;

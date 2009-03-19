# $Id$

package Pixis::API::Event;
use Moose;
use Pixis::API::Base::DBIC;
use POSIX qw(strftime);
use namespace::clean -except => qw(meta);

with 'Pixis::API::Base::DBIC';

around(__PACKAGE__->txn_method(create => sub {
    my ($next, $self, $args) = @_;

    my $event = $next->($self, $args);
    Pixis::Registry->get(api => 'EventTrack')->create({
        event_id => $event->id,
        title    => 'Track 1'
    });
    return $event;
}));

around(__PACKAGE__->txn_method(create_from_form => sub {
    my ($next, $self, $args) = @_;

    my $event = $next->($self, $args);
    Pixis::Registry->get(api => 'EventTrack')->create({
        event_id => $event->id,
        title    => 'Track 1',
        created_on => DateTime->now,
    });
    return $event;
}));

__PACKAGE__->txn_method(add_session => sub {
    my ($self, $args) = @_;

    # If this event doesn't have a track, then create one.
    # The default track will just have a name Track 1
    my $track_api = Pixis::Registry->get(api => 'EventTrack');
    my $track;

    if (my $track_id = $args->{track_id}) {
        $track = $track_api->find($track_id);
    } else {
        $track = $track_api->load_or_create_default_track($args);
    }

    $track_api->add_session(
        {
            %$args,
            track_id => $track->id,
        }
    );
});

sub load_tracks {
    Pixis::Registry->get(api => 'EventTrack')->load_from_event($_[1]);
}

sub load_sessions {
    my ($self, $args) = @_;

    my $track_api = Pixis::Registry->get(api => 'EventTrack');
    my $track;
    if (my $track_id = $args->{track_id}) {
        $track = $track_api->find($track_id);
    } else {
        $track = $track_api->load_or_create_default_track($args);
    }
    $track_api->load_sessions({ track_id => $track->id });
}

sub load_sessions_from_date {
    my ($self, $args) = @_;

    my $event = $self->find($args->{event_id});
    my $date = $args->{date} || $event->start_on;

    Pixis::Registry->get(api => 'EventSession')
        ->load_from_date({ event_id => $event->id, start_on => $date });
}

sub load_coming {
    my ($self, $args) = @_;

    my @ids = $self->resultset->search(
        { 
            -and => [
                start_on => { '<=' => $args->{max} },
                start_on => { '>'  => strftime('%Y-%m-%d', localtime) },
            ]
        },
        {
            select => [ 'id' ]
        }
    );

    return $self->load_multi(map { $_->id } @ids);
}

sub is_registration_open {
    my ($self, $args) = @_;

    my $event = $self->find($args->{event_id});
    return () if (! $event);

    my $now = DateTime->now;
    return $event->is_registration_open &&
        $event->registration_start_on >= $now &&
        $event->registration_end_on <= $now
    ;
}


__PACKAGE__->meta->make_immutable;
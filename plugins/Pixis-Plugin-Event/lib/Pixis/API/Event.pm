# $Id$

package Pixis::API::Event;
use Moose;
use Pixis::API::Base::DBIC;
use POSIX qw(strftime);
use namespace::clean -except => qw(meta);

with 'Pixis::API::Base::DBIC';

around(txn_method create => sub {
    my ($next, $self, $args) = @_;

    my $event = $next->($self, $args);
    Pixis::Registry->get(api => 'EventTrack')->create({
        event_id => $event->id,
        title    => 'Track 1'
    });
    return $event;
});

around(txn_method create_from_form => sub {
    my ($next, $self, $args) = @_;

    my $event = $next->($self, $args);
    Pixis::Registry->get(api => 'EventTrack')->create({
        event_id => $event->id,
        title    => 'Track 1',
        created_on => DateTime->now,
    });
    return $event;
});

txn_method add_session => sub {
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
};

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

sub load_coming {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get('schema' => 'master');
    my @ids = $schema->resultset('Event')->search(
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


__PACKAGE__->meta->make_immutable;
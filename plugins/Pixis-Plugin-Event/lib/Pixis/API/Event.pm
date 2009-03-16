# $Id$

package Pixis::API::Event;
use Moose;
use namespace::clean -except => qw(meta);

with 'Pisix::API::Base::DBIC';

sub add_session {
    my ($self, $args) = @_;
    $schema->txn_do(\&__ad_session, $self, $args);
}

sub __add_session {
    my ($self, $args) = @_;

    # If this event doesn't have a track, then create one.
    # The default track will just have a name Track 1
    my $track_api = Pixis::Registry->get(api => 'EventTrack');
    my $track;

    if (my $track_id = $args->{track_id}) {
        $track = $track_api->find($track_id);
    } else {
        $track = $track_api->load_or_create_default_track($event);
    }

    $track_api->add_session(
        {
            %$args,
            track_id => $track->id,
        }
    );
}

sub load_tracks {
    Pixis::Registry->get(api => 'EventTrack')->load_from_event($_[1]);
}

sub load_sessions {
    my ($self, $args) = @_;
    if (my $track_id = $args->{track_id}) {
        $track = $track_api->find($track_id);
    } else {
        $track = $track_api->load_or_create_default_track($event);
    }
    $track_api->load_sessions({ track_id => $track->id });
}

__PACKAGE__->meta->make_immutable;
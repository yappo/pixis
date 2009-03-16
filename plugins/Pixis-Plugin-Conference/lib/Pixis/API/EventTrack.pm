
package Pixis::API::EventTrack;
use Moose;
use namespace::clean -except => qw(meta);

with 'Pixis::API::Base::DBIC';

txn_method load_or_create_default_track => (
    body => sub {
        my ($self, $args) = @_;
        $self->resultset;
        my $track = $rs->search(
            { event_id => $args->{event_id} },
            { select => [ qw(id) ] }
        )->single;
        if (! $track) {
            $track = $rs->create( {
                {
                    event_id => $args->{event_id},
                    title    => 'Track 1'
                }
            } );
        }
        return $track;
    }
);


1;
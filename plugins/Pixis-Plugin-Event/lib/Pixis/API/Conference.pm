# $Id: /mirror/pixis/Pixis-Plugin-Conference/trunk/lib/Pixis/API/Conference.pm 101229 2009-02-25T04:05:51.706623Z daisuke  $

package Pixis::API::Conference;
use Moose;
use POSIX ();

with 'Pixis::API::Base::DBIC';

__PACKAGE__->meta->make_immutable;

no Moose;

sub load_coming {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get('schema' => 'master');
    my @ids = $schema->resultset('Conference')->search(
        { 
            -and => [
                start_on => { '<=' => $args->{max} },
                start_on => { '>'  => POSIX::strftime('%Y-%m-%d', localtime) },
            ]
        },
        {
            select => [ 'id' ]
        }
    );

    return $self->load_multi(map { $_->id } @ids);
}

sub load_tracks {
    my ($self, $id) = @_;

    my $schema = Pixis::Registry->get('schema' => 'master');
    my @ids = map { $_->id } $schema->resultset('ConferenceTrack')->search(
        {
            conference_id => $id
        },
        {
            select => [ qw(id) ]
        }
    );

use Data::Dumper;
Pixis::Web->log->debug( Dumper( \@ids ) );

    return [ Pixis::Registry->get(api => 'ConferenceTrack')->load_multi(@ids) ];
}

1;
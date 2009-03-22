
package Pixis::Plugin::Event;
use Moose;

with 'Pixis::Plugin';

has '+extra_api' => (
    default => sub {
        [ qw(Event EventDate EventTrack EventSession) ]
    }
);

__PACKAGE__->meta->make_immutable;
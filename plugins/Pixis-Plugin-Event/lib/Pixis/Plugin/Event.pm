
package Pixis::Plugin::Event;
use Moose;

with 'Pixis::Plugin';

has '+extra_api' => (
    default => sub {
        [ qw(Event EventDate EventRegistration EventSession EventTrack EventTicket) ]
    }
);

__PACKAGE__->meta->make_immutable;
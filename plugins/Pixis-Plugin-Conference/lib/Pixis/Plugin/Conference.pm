# $Id: /mirror/pixis/Pixis-Plugin-Conference/trunk/lib/Pixis/Plugin/Conference.pm 101271 2009-02-27T05:53:14.753641Z daisuke  $

package Pixis::Plugin::Conference;
use Moose;
use MooseX::AttributeHelpers;
use DateTime;

with 'Pixis::Plugin';

has '+navigation' => (
   default => sub {
       { 
           text => "Conference",
           url => "/conference"
       }
    }
);

has '+extra_api' => (
    default => sub {
        [ qw(Conference ConferenceTrack ConferenceSession) ]
    }
);

__PACKAGE__->meta->make_immutable;

no Moose;

1;
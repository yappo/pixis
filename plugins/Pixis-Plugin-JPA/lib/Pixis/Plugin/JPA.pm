# $Id$

package Pixis::Plugin::JPA;
use Moose;

with 'Pixis::Plugin';

has '+navigation' => (
    default => sub {
        [
            {
                text => "JPA",
                url  => "/jpa"
            },
            {
                text => "Wiki",
                url  => "http://wiki.perlassociation.org"
            }
        ]
    }
);

has '+extra_api' => (
    default => sub { +[ qw(JPAMember) ] }
);

no Moose;

1;
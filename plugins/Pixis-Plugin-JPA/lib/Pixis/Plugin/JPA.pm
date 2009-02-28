# $Id$

package Pixis::Plugin::JPA;
use Moose;

with 'Pixis::Plugin';

has '+extra_api' => (
    default => sub { +[ qw(JPAMember) ] }
);

no Moose;

1;
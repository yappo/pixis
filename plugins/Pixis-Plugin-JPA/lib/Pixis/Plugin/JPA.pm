# $Id$

package Pixis::Plugin::JPA;
use Moose;

with 'Pixis::Plugin';

has '+navigation' => (
    default => sub {
        {
            text => "JPA",
            url  => "/jpa"
        }
    }
);

has '+extra_api' => (
    default => sub { +[ qw(JPAMember JPAPaymentHistory) ] }
);

no Moose;

1;
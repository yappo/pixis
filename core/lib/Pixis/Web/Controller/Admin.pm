# $Id$

package Pixis::Web::Controller::Admin;
use strict;
use base qw(Catalyst::Controller);

sub auto :Private {
    my ($self, $c) = @_;
    $c->forward('/auth/assert_roles', [ 'admin' ]);
}

1;
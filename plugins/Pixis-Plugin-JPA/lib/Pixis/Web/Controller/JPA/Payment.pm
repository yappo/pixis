
package Pixis::Web::Controller::JPA::Payment;
use strict;
use base qw(Catalyst::Controller);

sub auto :Private {
    my ($self, $c) = @_;
    $c->forward('/auth/assert_logged_in');
}

sub bank :Local :Args(0) {}

1;
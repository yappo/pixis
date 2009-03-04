
package Pixis::Web::Controller::JPA;
use strict;
use base qw(Catalyst::Controller);

sub index :Index :Args(0) {}
sub poweredby :Local :Args(0) {}

1;
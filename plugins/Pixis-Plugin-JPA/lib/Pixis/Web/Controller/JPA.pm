
package Pixis::Web::Controller::JPA;
use strict;
use base qw(Catalyst::Controller);

sub index :Index :Args(0) {
    my ($self, $c) = @_;
    if ($c->user_exists) {
#        my $member = $c->registry(api => 'JPAMember')->find_from_member($c->user->id);
    }
}

1;
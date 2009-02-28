
package Pixis::Web::Controller::Signup;
use strict;
use warnings;
use parent qw(Catalyst::Controller::HTML::FormFu);

# Ask things like name, and email address
sub start :Index :Path :Args(0) :FormConfig {
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        my $hash = $c->generate_session_id;
        my $params = $form->params;
        delete $params->{password_check}; # no need to include it here
        $c->session->{ signup }->{ $hash } = $params;
        $c->res->redirect(
            $c->uri_for('experience', $hash)
        );
    }
}

# Ask things like coderepos/github accounts
sub experience :Local :Args(1) :FormConfig {
    my ($self, $c, $session) = @_;

    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        $c->session->{signup}->{$session} = 
            Catalyst::Utils::merge_hashes($c->session->{signup}->{$session}, scalar $form->params);
        $c->res->redirect(
            $c->uri_for('commit', $session)
        );
    }
}

# All done, save
sub commit :Local :Args(1) {
    my ($self, $c, $session) = @_;

    my $hash = $c->session->{signup}->{$session} ;
    # submit element will exist... remove
    delete $hash->{submit};
    my $member = $c->model('API')->get(api => 'Member')->create($hash);
    if ($member) {
        $c->session->{signup}->{$session} = $member->id;
        $c->res->redirect($c->uri_for('done', $session));
    }
}

sub done :Local {
    my ($self, $c, $session) =  @_;
    my $id = delete $c->session->{signup}->{$session};
    $c->res->redirect($c->uri_for('/member', $id));
}

1;
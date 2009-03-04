# $Id$

package Pixis::Web::Controller::JPA::Signup;
use strict;
use base qw(Catalyst::Controller::HTML::FormFu);

# Signup overview
#   1 - you're already a pixis user. good.
#   2 - verify addresses and such. these are not required for pixis
#       itself, but is required for JPA
#   3 - do a pre-registration. Insert into database, but
#       the payment status is "unpaid"
#
#   Path 1: paypal (or some other online, synchronous payment)
#   4A  - upon verfication form paypal, set the status.
#         you're done. (XXX - admin may want notification)
#
#   Path 2: bank transfer, convenience stores, etc.
#   4B - verify payment by hand (how unfortunate).
#        We need an admin view for this

sub index :Index :Args(0) {}

sub contd :Local :Args(1) {
    my ($self, $c, $subsession) = @_;
    $c->stash->{subsession} = $subsession;
}

sub basic :Local :Args(0) :FormConfig {
    my ($self, $c) = @_;

    $c->forward('/auth/assert_logged_in') or return;

    my $form = $c->stash->{form};

    my $user = $c->registry(api => 'Member')->find($c->user->id);
    $form->model->default_values( $user );
    if ($form->submitted_and_valid) {
        my $hash = $c->generate_session_id;
        my $params = $form->params;
        # remove extraneous stuff
        delete $params->{submit};

        $c->session->{jpa_signup}->{$hash} = $params;
        $c->res->redirect($c->uri_for('confirm_basic', $hash));
    }
}

sub confirm_basic :Local :Args(1) {
    my ($self, $c, $session) = @_;

    $c->forward('/auth/assert_logged_in') or return;
    if( !($c->stash->{confirm} = $c->session->{jpa_signup}->{$session})) {
        $c->res->redirect($c->uri_for('/jpa', 'signup'));
        return;
    }
    $c->stash->{subsession} = $session;
}

sub commit_basic :Local :Args(1) {
    my ($self, $c, $session) = @_;
    $c->forward('/auth/assert_logged_in') or return;

    my $params;
    if( !($params = delete $c->session->{jpa_signup}->{$session})) {
        $c->res->redirect($c->uri_for('/jpa', 'signup'));
        return;
    }
    # commit this basic information.
    $params->{member_id} = $c->user->id;
    my ($jpa_member, $order) = $c->registry(api => 'JPAMember')->create($params);
    $c->stash->{order} = $order;
    $c->stash->{jpa_member} = $jpa_member;
}

sub payment :Local :Args(0) {
    my ($self, $c) = @_;
    $c->forward('/auth/assert_logged_in') or return;
}

1;
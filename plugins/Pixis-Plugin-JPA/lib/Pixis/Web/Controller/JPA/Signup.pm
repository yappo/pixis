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

sub basic :Local :Args(0) :FormConfig {
    my ($self, $c) = @_;

    my $form = $c->stash->{form};

    my $user = $c->registry(api => 'Member')->find($c->user->id);
    $form->model->default_values( $user );
    if ($form->submitted_and_valid) {
        my $hash = Digest::SHA1->new()->add(time(), {}, $$, rand())->hexdigest();
        my $params = $form->params;
        $c->session->{jpa_signup}->{$hash} = $params;
        $c->res->redirect($c->uri_for('confirm', $hash));
    }
}

sub confirm_basic :Local :Args(1) {
    my ($self, $c, $session) = @_;

    $c->stash->{subsession} = $session;
    $c->stash->{confirm} = $c->session->{jpa_signup}->{$session};
}

sub commit_basic :Local :Args(1) {

}

sub payment :Local :Args(0) {
}

1;
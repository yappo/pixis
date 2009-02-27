# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/Web/Controller/Auth.pm 101264 2009-02-27T05:10:06.352581Z daisuke  $

package Pixis::Web::Controller::Auth;
use strict;
use warnings;
use base qw(Catalyst::Controller::HTML::FormFu);

sub fail : Private {
    my ($self, $c) = @_;
    $c->res->body("You don't have permission to use this resource");
}

sub assert_logged_in :Private {
    my ($self, $c) = @_;
    if (! $c->user_exists) {
        $c->session->{next_uri} = $c->req->uri;
        $c->res->redirect($c->uri_for('/auth/login'));
        return ();
    }
    return 1;
}

sub assert_roles : Private{
    my ($self, $c, @args) = @_;

    $self->assert_logged_in($c) or return ();
    if (! $c->check_user_roles(@args)) {
        $c->forward('/auth/fail');
        return ();
    }
    return 1;
}

{ # XXX - TODO Create a C::Auth::Store subclass that doesn't require
  # this horrible, horrible workaround
    package FudgeWorkAround;
    sub new {
        bless [ $_[1] ], $_[0];
    }
    sub first { $_[0]->[0] }
}

sub login :Local :FormConfig {
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        # here's a little trickery
        my $email = $form->param('email');
        my ($auth) = Pixis::Registry->get(api => 'MemberAuth')->load_auth({
            email => $email,
            auth_type => 'password'
        });
        $c->log->debug("Loaded auth information for $email (" . ($auth || ('null')) . ")") if $c->log->is_debug;

        # if no auth, then you're no good
        if ($auth) {
            # okie dokie, remember the milk, and load a resultset
            # XXX - there *HAS* to be a better way

            my $member = Pixis::Registry->get(api => 'Member')->load_from_email($auth->email);
            $member->password($auth->auth_data);
            my $dummy = FudgeWorkAround->new($member);

            $c->log->debug("Authenticating against user $member") if $c->log->is_debug;
            if ($c->authenticate({ password => $form->param('password'), dbix_class => { resultset => $dummy } }, 'members')) {
                $c->res->redirect(
                    $c->session->{next_uri} ||
                    $c->uri_for('/member', $c->user->id)
                );
                return;
            }
        }

        # if you got here, the login was a failure
        $form->form_error_message( 
            $c->localize("Authentication failed"));
        $form->force_error_message(1);
    }
}

sub openid :Local :FormConfig {
    my ($self, $c) = @_;

    if ($c->req->param('openid-check')) {
        if ($c->authenticate({}, 'openid')) {
            # here's the tricky bit. OpenID sign-on is a two phase thing.
            # we now know that the remote openid provider has authenticated
            # this guy, but we don't know if he's in our books.

            my ($auth) = Pixis::Registry->get(api => 'MemberAuth')->load_auth(
                {
                    auth_type => 'openid',
                    auth_data => $c->req->param('openid.identity')
                },
            );
            if ($auth) {
                $c->user( Pixis::Registry->get(api => 'Member')->load_from_email($auth->email) );

                $c->res->redirect(
                    $c->session->{next_uri} ||
                    $c->uri_for('/member', $c->user->id)
                );
                return;
            }
        }
    }
    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {

        if ($c->authenticate({ openid_identifier => $form->param('openid_identifier') }, 'openid')) {
            $c->res->redirect(
                $c->session->{next_uri} ||
                $c->uri_for('/member', $c->user->id)
            );
            return;
        }
    }
}

sub logout :Local {
    my ($self, $c) = @_;

    $c->delete_session;
    $c->res->redirect($c->uri_for('/'));
}

1;
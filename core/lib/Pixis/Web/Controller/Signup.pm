
package Pixis::Web::Controller::Signup;
use utf8;
use strict;
use warnings;
use parent qw(Catalyst::Controller::HTML::FormFu);

__PACKAGE__->mk_accessors($_) for qw(steps);

sub COMPONENT {
    my ($self, $c, $config) = @_;
    $self = $self->NEXT::COMPONENT($c, $config);

    $self->steps(['experience', 'commit', 'send_activate' ]) unless $self->steps;
    $self;
}

# Ask things like name, and email address
sub start :Index :Path :Args(0) :FormConfig {
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        # check if this email has already been taken
        if ( $c->registry(api => 'Member')->load_from_email($form->param('email')) ) {
            $form->form_error_message("使用されたメールアドレスはすでに登録されています");
            $form->force_error_message(1);
            return;
        }

        my $params = $form->params;
        delete $params->{password_check}; # no need to include it here
        delete $params->{current_step};
        my $subsession = $self->new_subsession($c, $params);
        $c->detach('next_step', [$subsession]);
    }
}

sub next_step :Private {
    my ($self, $c, $subsession) = @_;
    my $p = $self->get_subsession($c, $subsession);

    my $step;
    if (! exists $p->{current_step} ) {
        $step = $self->steps->[0];
    } else {
        # find the step with the same name
        my $cur   = $p->{current_step};
        my $steps = $self->steps;
        foreach my $i (0..$#{$steps}) {
warn "checking $cur against $steps->[$i]";
            if ($steps->[$i] eq $cur) {
                if ($i == $#{$steps}) {
                    $step = 'done';
                } else {
                    $step = $steps->[$i + 1];
                }
            }
        }
    }
warn "step is $step";

    if (! $step) {
        $self->delete_subsession($c, $subsession);
        $c->detach('/default');
    }
    $p->{current_step} = $step;
    $self->set_subsession($c, $subsession, $p);

    my $uri = $c->uri_for($step, $subsession );
    $c->log->debug("Next step is forwading to $uri") if $c->log->is_debug;
    $c->res->redirect( $uri );
}

# Ask things like coderepos/github accounts
sub experience :Local :Args(1) :FormConfig {
    my ($self, $c, $subsession) = @_;

    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        my $p = $self->get_subsession($c, $subsession);
        my $params = Catalyst::Utils::merge_hashes($p, scalar $form->params);
        $self->set_subsession($c, $subsession, $params);
        $c->detach('next_step', [$subsession]); 
    }
}

# All done, save
sub commit :Local :Args(1) {
    my ($self, $c, $subsession) = @_;

    my $p = $self->get_subsession($c, $subsession);
    # submit element will exist... remove
    delete $p->{submit};
    delete $p->{current_step};
    my $member = $c->registry(api => 'Member')->create($p);
    if ($member) {
        $p->{current_step} = 'commit';
        $p->{activation_token} = $member->activation_token;
        $self->set_subsession($c, $subsession, $p);
        $c->detach('next_step', [$subsession]);
    } 
}

sub activate :Loca :Args(0) :FormConfig {
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    if ($c->registry(api => 'Member')->activate($form->param('key'))) {
        # we've activated. now start a new subsession, so we can forward to
        # whatever next step 
        my $subsession = $self->new_subsession($c, {current_step => 'activate'});
        $c->detach('next_step', [$subsession]);
    }
}

sub send_activate :Local :Args(1) {
    my ($self, $c, $subsession) = @_;

    my $p = $self->get_subsession($c, $subsession);

    $c->stash->{ activation_token } = $p->{activation_token};

    my $body = $c->view('TT')->render($c, 'signup/activation_email.tt');
    $body = Encode::encode('iso-2022-jp', $body);
    $c->stash->{email} = {
        to => $p->{email},
        from => 'no-reply@pixis',
        subject => Encode::encode('MIME-Header', "登録アクティベーションメール"),
        body    => $body,
        content_type => 'text/plain; charset=iso-20220-jp',
    };
        
    $c->forward( $c->view('Email' ) );
    $c->res->redirect($c->uri_for('activate'));
}

sub done :Local {
    my ($self, $c, $subsession) =  @_;
    my $id = delete $c->session->{signup}->{$subsession};
    $c->res->redirect($c->uri_for('/member', $id));
}

sub new_subsession {
    my ($self, $c, $value) = @_;
    my $subsession = $c->generate_session_id;
    $self->set_subsession($c, $subsession, $value);
    return $subsession;
}

sub get_subsession {
    my ($self, $c, $subsession) = @_;
    $c->session->{__subsessions}->{$subsession};
}

sub set_subsession {
    my ($self, $c, $subsession, $value) = @_;
    $c->session->{__subsessions}->{$subsession} = $value;
}

sub delete_subsession {
    my ($self, $c, $subsession, $value) = @_;
    delete $c->session->{__subsessions}->{$subsession};
}

1;
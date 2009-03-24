package Pixis::Web::Controller::Event::Payment::Paypal;
use strict;
use base qw(Pixis::Web::Controller::Payment::Paypal);

sub COMPONENT {
    my ($self, $c, $config) = @_;
    $config->{complete_url} ||= '/event/payment/paypal/complete';
    $self = $self->NEXT::COMPONENT($c, $config);
}

sub complete :Local {
    my ($self, $c) = @_;

    $self->SUPER::complete($c);

    # if the order is complete, activate the registration status
    my $api = $c->registry(api => 'EventRegistration');
    my $registration = $api->load_from_order(
        {
            order_id => $c->stash->{order}->id,
            member_id => $c->user->id,
        }
    );
    $api->activate({ id => $registration->id });

    $c->stash->{template} = 'payment/paypal/complete.tt';
}

1;

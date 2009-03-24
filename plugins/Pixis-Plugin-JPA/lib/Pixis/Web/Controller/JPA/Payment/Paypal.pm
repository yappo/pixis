package Pixis::Web::Controller::JPA::Payment::Paypal;
use strict;
use base qw(Pixis::Web::Controller::Payment::Paypal);

sub COMPONENT {
    my ($self, $c, $config) = @_;
    $config->{complete_url} ||= '/jpa/payment/paypal/complete';
    return $self->NEXT::COMPONENT($c, $config);
}

sub complete :Local {
    my ($self, $c) = @_;

    $self->SUPER::complete($c);
    my $order = $c->stash->{order};
    my $jpa_member_api = $c->registry(api => 'jpamember');
    my ($jpa_member) = $jpa_member_api->search(
        {
            member_id => $order->member_id
        }
    );
    $jpa_member_api->update(
        {
            id => $jpa_member->id,
            is_active => 1
        }
    );

    $c->stash->{template} = 'payment/paypal/complete.tt';
}

1;
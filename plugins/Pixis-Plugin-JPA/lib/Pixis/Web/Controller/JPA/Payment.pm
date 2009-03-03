
package Pixis::Web::Controller::JPA::Payment;
use strict;
use base qw(Catalyst::Controller::HTML::FormFu);

sub auto :Private {
    my ($self, $c) = @_;
    $c->forward('/auth/assert_logged_in');
}

sub paypal :Local :Args(0) :FormConfig{
    my ($self, $c) = @_;

    my $order;
    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        ($order) = $c->registry(api => 'Order')->search(
            {
                id        => $form->param('order'),
                member_id => $c->user->id,
                status    => &Pixis::Schema::Master::Order::ST_INIT,
            }
        );
    }

    if (! $order) {
        # XXX - huh?
        $c->log->debug("Order not found :(") if $c->log->is_debug;
        $c->forward('/default');
        return;
    }

    $c->controller('Payment::Paypal')->purchase($c, {
        order_id    => $order->id,
        return_url  => $c->uri_for('/jpa/payment/paypal/accept', { order => $form->param('order') } ),
        cancel_url  => $c->uri_for('/jpa/payment/paypal/cancel', { order => $form->param('order') }),
        amount      => $order->amount,
        member_id   => $c->user->id,
        description => $order->description,
    });
}

sub paypal_cancel :Path('paypal/cancel') {
    my ($self, $c) = @_;

    $c->controler('Payment::Paypal')->cancel($c, {
    } );
}

sub paypal_accept :Path('paypal/accept') :FormConfig{
    my ($self, $c) = @_;

    my $order;
    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        $c->log->debug("Loading order for paypal_accept: " . $form->param('order')) if $c->log->is_debug;
        $order = $c->registry(api => 'Order')->find($form->param('order'));
    }

    if (! $order) {
        # XXX - huh?
        $c->log->debug("Order not found :(") if $c->log->is_debug;
        $c->forward('/default');
        return;
    }

    # let the payment gateway do its thing. if it's okay, we shall proceed
    $c->controller('Payment::Paypal')->complete($c, {
        return_url => $c->uri_for('/jpa/payment/paypal/complete', { order => $form->param('order') }) ,
        cancel_url  => $c->uri_for('/jpa/payment/paypal/cancel', { order => $c->req->param('order') }),
        price       => $order->amount,
        member_id   => $c->user->id,
        description => $order->description,
        ext_id      => $form->param('token'),
        txn_id      => $form->param('txn'),
        order_id    => $form->param('order'),
        payer_id    => $form->param('PayerID'),
        
    } );
}

sub paypal_complete :Path('paypal/complete') :FormConfig{
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    if (! $form->submitted_and_valid) {
        $c->forward('/error', 'unknown order');
    }

    $c->log->debug("Loading order for paypal_complete: " . $form->param('order')) if $c->log->is_debug;
    my $order = $c->registry(api => 'Order')->find($form->param('order'));
    $c->registry(api => 'order')->change_status(
        {
            order_id => $form->param('order'),
            status   => &Pixis::Schema::Master::Order::ST_DONE,
        }
    );
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
    $c->stash->{order} = $order;
}

1;

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
                status    => &Pixis::Schema::Master::Order::ST_UNPAID,
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
        return_url  => $c->uri_for('/jpa/payment/paypal/complete'),
        cancel_url  => $c->uri_for('/jpa/payment/paypal/cancel', { payment => $form->param('order') }),
        price       => $order->amount,
        member_id   => $c->user->id,
        description => $order->description,
    });
}

sub paypal_cancel :Path('paypal/cancel') {
    my ($self, $c) = @_;

    $c->controler('Payment::Paypal')->cancel($c, {
    } );
}

sub paypal_complete :Path('paypa/complete') :FormConfig{
    my ($self, $c) = @_;

    my $txn;
    my $form = $c->stash->{form};
    # Ah, bummer, I haven't thought this out yet.
    if ($form->submitted_and_valid) {
        # find the transaction
        # $txn = $c->registry(api => payment => 'paypal')->load_txn( {
        #   token => $form->param('token'),
        #   payer_id => $form->param('PayerID'),
        # } );
    }

    if (! $txn) {
        $c->log->debug("Couldn't find transaction " . $form->param('token')) if $c->log->is_debug;
        $c->forward('/error', "Couldn't find paypal transaction " . $form->param('token'));
        return;
    }

    $c->controller('Payment::Paypal')->complete($c, {
        
    } );
}

1;
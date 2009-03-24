# $Id$

package Pixis::Web::Controller::Payment::Paypal;
use strict;
use base qw(Catalyst::Controller::HTML::FormFu);

sub auto :Private {
    my ($self, $c) = @_;
    $c->forward('/auth/assert_logged_in');
}

sub initiate_purchase :Private {
    my ($self, $c) = @_;

    my $order;
    my $form = $self->form;
    $form->load_config_file('payment/paypal/purchase.yml');
    $form->process($c->request);

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
        Pixis::Web::Exception->throw(
            safe_message => 1,
            message => "Requested order '" . $form->param('order') . "' was not found"
        );
    }

    my $args = {
        order_id    => $order->id,
        return_url  => $c->uri_for('accept', { order => $order->id }),
        cancel_url  => $c->uri_for('cancel', { order => $order->id }),
        amount      => $order->amount,
        member_id   => $c->user->id,
        description => $order->description
    };

    my $url = eval {
        $c->registry(api => 'payment' => 'paypal')->initiate_purchase($args);
    };
    if ($@) {
        $c->log->debug("Communication Paypal failed: $@") if $c->log->is_debug;
        $c->detach('/error', "Communication with PayPal failed");
        return;
    }

    $c->res->redirect($url);
}

sub complete_purchase :Private {
    my ($self, $c, $args) = @_;

    eval {
        $c->registry(api => 'payment' => 'paypal')->complete_purchase($args);
    };
    if ($@) {
        $c->log->debug("Communication Paypal failed: $@") if $c->log->is_debug;
        $c->forward('/error', "Communication with PayPal failed");
        return;
    }

    $c->res->redirect($args->{return_url});
}

sub index :Index :Args(0) {
    my ($self, $c) = @_;
    $self->initiate_purchase($c);
}

sub accept :Local {
    my ($self, $c) = @_;

    my $order;
    my $form = $self->form;
    $form->load_config_file('payment/paypal/accept.yml');
    $form->process($c->request);

    if ($form->submitted_and_valid) {
        $c->log->debug("Loading order for paypal_accept: " . $form->param('order')) if $c->log->is_debug;
        $order = $c->registry(api => 'Order')->find($form->param('order'));
    }

    if (! $order) {
        # XXX - huh?
        $c->log->debug("Order not found :(") if $c->log->is_debug;
        Pixis::Web::Exception->throw(
            safe_message => 1,
            message => "Requested order '" . $form->param('order') . "' was not found"
        );
        return;
    }

    # let the payment gateway do its thing. if it's okay, we shall proceed
    $c->controller('Payment::Paypal')->complete_purchase($c, {
        return_url => $c->uri_for('complete', { order => $form->param('order') }) ,
        cancel_url  => $c->uri_for('cancel', { order => $c->req->param('order') }),
        price       => $order->amount,
        member_id   => $c->user->id,
        description => $order->description,
        ext_id      => $form->param('token'),
        txn_id      => $form->param('txn'),
        order_id    => $form->param('order'),
        payer_id    => $form->param('PayerID'),

    } );
}

sub paypal_cancel :Local :FormConfig {
    my ($self, $c) = @_;

    $c->controler('Payment::Paypal')->cancel($c, {
    } );
}

sub complete :Local :FormConfig{
    my ($self, $c) = @_;

    my $form = $self->form;
    $form->load_config_file('payment/paypal/complete.yml');
    $form->process($c->request);

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
    $c->stash->{order} = $order;
}

1;

__END__
# $Id$

package Pixis::Web::Controller::Payment::Paypal;
use strict;
use base qw(Catalyst::Controller);

sub purchase :Private {
    my ($self, $c, $args) = @_;

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

sub complete :Private {
    my ($self, $c, $args) = @_;

    eval {
        $c->registry(api => 'payment' => 'paypal')->complete_purchase({
            token      => $args->{token},
            return_url => $args->{return_url},
            cancel_url => $args->{cancel_url},
            amount     => $args->{price},
            payer_id   => $args->{payer_id},
        });
    };
    if ($@) {
        $c->log->debug("Communication Paypal failed: $@") if $c->log->is_debug;
        $c->forward('/error', "Communication with PayPal failed");
        return;
    }

    $c->res->redirect($args->{return_url});
}

1;

__END__
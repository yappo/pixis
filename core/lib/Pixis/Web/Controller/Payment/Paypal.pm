# $Id$

package Pixis::Web::Controller::Payment::Paypal;
use strict;
use base qw(Catalyst::Controller);

sub purchase :Private {
    my ($self, $c, $args) = @_;

    my $url = eval {
        $c->registry(api => 'Payment::Paypal')->initiate_purchase({
            return_url => $args->{return_url},
            cancel_url => $args->{cancel_url},
            price      => $args->{price},
        });
    };
    if ($@) {
        $c->forward('/error', "Communication with PayPal failed");
        return;
    }

    $c->res->redirect($url);
}

sub complete :Private {
    my ($self, $c, $args) = @_;

    my $url = eval {
        $c->registry(api => 'Payment::Paypal')->complete_purchase({
            return_url => $args->{return_url},
            cancel_url => $args->{cancel_url},
            price      => $args->{price},
            payer_id   => $args->{payer_id},
        });
    };
    if ($@) {
        $c->forward('/error', "Communication with PayPal failed");
        return;
    }

    $c->res->redirect($url);
}

1;

__END__
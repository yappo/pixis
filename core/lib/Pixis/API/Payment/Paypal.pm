
package Pixis::API::Payment::Paypal;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::Path::Class;
use HTTP::Request::Common qw(POST);
use LWP::UserAgent;
use namespace::clean -except => qw(meta);
use constant DEBUG => $ENV{PIXIS_DEBUG} ? 1 : 0;

has 'user_agent' => (
    is => 'rw',
    isa => 'LWP::UserAgent',
    lazy_build => 1,
);

has 'mode' => (
    is => 'rw',
    isa => enum([ qw(production development) ]),
    required => 1,
    default => 'development'
);

has 'web_url' => (
    is => 'rw',
    isa => 'Str',
    lazy_build => 1,
);

has 'api_url' => (
    is => 'rw',
    required => 1,
    lazy_build => 1,
);

has 'username' => (
    is => 'rw',
    required => 1,
    default => 'daisuk_1235727902_biz_api1.perlassociation.org',
);

has 'password' => (
    is => 'rw',
    required => 1,
    default => '1235727980',
);

has 'signature' => (
    is => 'rw',
    required => 1,
    default => 'An5ns1Kso7MWUdW4ErQKJJJ4qi4-AYLktabNtq8Xnd6.Sd.qcwF99IHm',
);

has 'version' => (
    is => 'rw',
    required => 1,
    default => '56.0'
);

__PACKAGE__->meta->make_immutable;

sub _build_user_agent {
    return LWP::UserAgent->new(
        agent => "Pixis UA"
    );
}

sub _build_web_url {
    my $self = shift;
    $self->mode eq 'production' ?
        'https://www.paypal.com' :
        'https://www.sandbox.paypal.com'
    ;
}

sub _build_api_url {
    my $self = shift;
    $self->mode eq 'production' ?
        'https://api-3t.paypal.com/nvp' :
        'https://api-3t.sandbox.paypal.com/nvp'
    ;
}

sub auth_parameters {
    my $self = shift;
    return (
        USER      => $self->username,
        PWD       => $self->password,
        SIGNATURE => $self->signature,
        VERSION   => $self->version
    );
}

sub initiate_purchase {
    my ($self, $args) = @_;

    my $order_id        = $args->{order_id} or confess "no order_id";
    my $cancel_url      = $args->{cancel_url} or confess "no cancel_url";
    my $return_url      = $args->{return_url} or confess "no return_url";
    my $amount          = $args->{amount} or confess "no amount";
    my $member_id       = $args->{member_id} or confess "no member_id";
    my $description     = $args->{description} or confess "no description";
    my @auth_parameters = $self->auth_parameters;

    # Before sending stuff to Paypal, create a transaction record
    my $order_api = Pixis::Registry->get(api => 'order');

    my $txn = $order_api->create_txn( {
        order_id => $order_id,
        txn => {
            txn_type => 'paypal',
            amount   => $amount,
        }
    });
    $return_url->query_form($return_url->query_form, txn => $txn->id);
    my @query = (
        method       => 'SetExpressCheckout',
        useraction   => 'commit',
        cancelurl    => $cancel_url,
        returnurl    => $return_url,
        amt          => $amount,
        currencycode => 'JPY',
        noshipping   => 1,
        solutiontype => 'SOLE'
    );

    my $uri = URI->new($self->api_url);
    $uri->query_form(@auth_parameters, @query);

    my $response = $self->user_agent->request(HTTP::Request->new(GET => $uri));
    if (! $response->is_success) {
        my $message = "HTTP request to paypal failed: " .  $response->code . ", " . $response->message;
        $order_api->change_status( {
            order_id  => $order_id,
            status    => &Pixis::Schema::Master::Order::ST_SYSTEM_ERROR,
            message   => $message,
            txn => {
                id => $txn->id,
                txn_type => 'paypal',
            }
        } );
        confess $message;
    }

    my $result = do {
        my $uri = URI->new();
        $uri->query($response->content);
        +{ $uri->query_form }
    };

    if (DEBUG()) {
        require Data::Dumper;
        print STDERR 
            "Set request $uri\n",
            "   -> got response:\n",
            ( map { "      $_\n" } split(/\n/, $response->as_string) ), "\n",
            "   -> decompose to ", Data::Dumper::Dumper($result), "\n",
        ;
    }

    if ( $result->{ACK} ne 'Success') {
        my $message = "Request to paypal failed: " . $response->as_string;
        $order_api->change_status(
            {
                order_id => $order_id,
                status => &Pixis::Schema::Master::Order::ST_SYSTEM_ERROR,
                message => $message,
                txn => {
                    id       => $txn->id,
                    txn_type => 'paypal',
                    status   => 'PAYPAL_ERROR',
                }
            }
        );
        confess $message;
    }

    my $token = $result->{TOKEN};
    my $next_uri = URI->new($self->web_url);
    $next_uri->path("/cgi-bin/webscr");
    $next_uri->query_form(cmd => '_express-checkout', token => $token);

    $order_api->change_status(
        {
            order_id => $order_id,
            status => &Pixis::Schema::Master::Order::ST_CREDIT_CHECK,
            txn => {
                id       => $txn->id,
                txn_type => 'paypal',
                ext_id   => $token,
                status   => 'PAYPAL_PROCESSING',
            },
        }
    );

    if (DEBUG()) {
        print STDERR "Returning url $next_uri\n";
    }
    return $next_uri;
}

sub complete_purchase {
    my ($self, $args) = @_;

    my $order_id  = $args->{order_id};

    my $order_api = Pixis::Registry->get(api => 'order');
    my $order   = $order_api->match_txn(
        {
            order_id => $order_id,
            txn => {
                id => $args->{txn_id},
                ext_id => $args->{ext_id}
            }
        }
    );

    if (! $order) {
        confess "Could not load order id + txn id: $order_id, $args->{txn_id}, $args->{ext_id}";
    }

    # Update the previous transation, so we can log that the user successfully
    # came back
    $order_api->change_status(
        {
            order_id => $order_id,
            status   => &Pixis::Schema::Master::Order::ST_CREDIT_ACCEPT,
            txn      => {
                id => $args->{txn_id},
                txn_type => 'paypal',
                status => 'PAYPAL_CHECK_CREDIT_DONE',
            }
        }
    );

    # And create a new one, this one for the final charge
    my $txn = $order_api->create_txn(
        {
            order_id => $order_id,
            txn => {
                txn_type => "paypal",
                amount   => $order->amount,
            }
        }
    );

    my $cancel_url      = $args->{cancel_url};
    my $return_url      = $args->{return_url};
    my $amount          = $order->amount,
    my $payer_id        = $args->{payer_id};
    my $token           = $args->{ext_id};
    my @auth_parameters = $self->auth_parameters;
    my @query = (
        method => 'DoExpressCheckoutPayment',
        useraction => 'commit',
        amt => $amount,
        currencycode => 'JPY',
        paymentaction => 'sale',
        payerid => $payer_id,
        token => $token
    );

    my $uri = URI->new($self->api_url);
    $uri->query_form(@auth_parameters, @query);

    my $response = $self->user_agent->request(HTTP::Request->new(GET => $uri));
    if (! $response->is_success) {
        my $message = "HTTP Request failed: " . $response->code . ", " . $response->message;
        $order_api->change_status(
            {
                order_id => $order_id,
                message  => $message,
                status   => &Pixis::Schema::Master::Order::ST_SYSTEM_ERROR,
                txn      => {
                    id => $txn->id,
                    txn_type => 'paypal',
                    status   => 'PAYPAL_ERROR',
                }
            }
        );
        confess $message;
    }
    my $result = do {
        my $uri = URI->new();
        $uri->query($response->content);
        +{ $uri->query_form }
    };

    if (DEBUG()) {
        require Data::Dumper;
        print STDERR 
            "Set request $uri\n",
            "   -> got response:\n",
            ( map { "      $_\n" } split(/\n/, $response->as_string) ), "\n",
            "   -> decompose to ", Data::Dumper::Dumper($result), "\n",
        ;
    }

    if ( $result->{ACK} ne 'Success') {
        my $message = "Request to paypal failed " . $response->as_string;
        $order_api->change_status(
            {
                order_id => $order_id,
                message  => $message,
                status   => &Pixis::Schema::Master::Order::ST_SYSTEM_ERROR,
                txn      => {
                    id => $txn->id,
                    txn_type => 'paypal',
                    status   => 'PAYPAL_ERROR',
                }
            }
        );
        confess $message;
    }

    $order_api->change_status(
        {
            order_id => $order_id,
            status   => &Pixis::Schema::Master::Order::ST_DONE,
            message => join(', ', map { "$_ => $result->{$_}" } qw(CORRELATION_ID TXN_ID) ),
            txn      => {
                id => $txn->id,
                txn_type => 'paypal',
                status => 'PAYPAL_DONE',
            }
        }
    );
}

1;
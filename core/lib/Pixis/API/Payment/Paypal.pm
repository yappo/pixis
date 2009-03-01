
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

has 'openssl_cmd' => (
    is => 'rw',
    isa => 'Path::Class::File',
#    required => 1
);

has 'mode' => (
    is => 'rw',
    isa => enum([ qw(producation development) ]),
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
    isa => 'Str',
    required => 1,
);

has 'password' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has 'signature' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has 'version' => (
    is => 'rw',
    isa => 'Str',
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

    my $cancel_url      = $args->{cancel_url};
    my $return_url      = $args->{return_url};
    my $price           = $args->{price};
    my @auth_parameters = $self->auth_parameters;
    my @query = (
        method       => 'SetExpressCheckout',
        useraction   => 'commit',
        cancelurl    => $cancel_url,
        returnurl    => $return_url,
        amt          => $price,
        currencycode => 'JPY',
        noshipping   => 1,
        solutiontype => 'SOLE'
    );

    my $uri = URI->new($self->api_url);
    $uri->query_form(@auth_parameters, @query);
    my $response = $self->user_agent->request(HTTP::Request->new(GET => $uri));
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
        confess "Request to paypal failed " . $response->as_string;
    }

    my $token = $result->{TOKEN};
    my $uri = URI->new($self->web_url);
    $uri->path("/cgi-bin/webscr");
    $uri->query_form(cmd => '_express-checkout', token => $token);

    if (DEBUG()) {
        print STDERR "Returning url $uri\n";
    }
    return $uri;
}

sub encrypt_and_sign {
    my ($self, $form) = @_;

    my $openssl = $self->openssl_cmd;
    my $pp_cert = $self->pp_cert;

    my $my_cert = $self->my_cert;
    my $my_key  = $self->my_key;
    my $mey_cert_id = $self->my_cert_id;
}


1;
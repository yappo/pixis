# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/API/Payment/Paypal.pm 99505 2009-02-03T03:28:19.287739Z daisuke  $

package Pixis::API::Payment::Paypal;
use Moose;
use MooseX::Types::Path::Class;
use IPC::Open2;

has 'openssl_cmd' => (
    is => 'rw',
    isa => 'Path::Class::File',
    required => 1
);

__PACKAGE__->meta->make_immutable;

no Moose;

sub encrypt_and_sign {
    my ($self, $form) = @_;

    my $openssl = $self->openssl_cmd;
    my $pp_cert = $self->pp_cert;

    my $my_cert = $self->my_cert;
    my $my_key  = $self->my_key;
    my $mey_cert_id = $self->my_cert_id;
}

1;
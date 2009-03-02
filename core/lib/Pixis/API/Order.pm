
package Pixis::API::Order;
use Moose;
use namespace::clean -except => qw(meta);

with 'Pixis::API::Base::DBIC';

sub __create_txn {
    my ($self, $schema, $args) = @_;

    my $txn_args = $args->{txn};
    $schema->resultset('PaymentTransaction')->create(
        {
            %$txn_args,
            order_id => $args->{order_id},
            created_on => \'NOW()',
        }
    );
}

sub create_txn {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get(schema => 'master');
    $schema->txn_do( \&__create_txn, $self, $schema, $args );
}

sub __change_status {
    my ($self, $schema, $args) = @_;

    my $order = $self->find($args->{order_id});
    if (! $order) {
        confess "No such order: $args->{order_id}";
    }

    if (my $txn = $args->{txn}) {
        local $txn->{order_id} = $args->{order_id};
        $self->change_txn_status($txn);
    }

    my $old = $order->status();
    $order->status($args->{status});
    $order->update;

    my $message = "CHANGE $old => $args->{status} " . ($args->{message} || '');

    $self->log_action( {
        order_id => $order->id,
        message => $message
    } );
}

sub change_status {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get(schema => 'master');
    $schema->txn_do( \&__change_status, $self, $schema, $args );
}

sub log_action {
    my ($self, $args) = @_;

    my $order = $self->find( $args->{order_id} );
    if (! $order) {
        confess "No such order: $args->{order_id}";
    }

    Pixis::Registry->get(schema => 'master')->resultset('OrderAction')->create( {
        order_id => $order->id,
        message  => $args->{message}
    } );
}

sub __change_txn_status {
    my ($self, $schema, $args) = @_;

    my $txn = $schema->resultset('PaymentTransaction')->search(
        {
            id => $args->{id},
            order_id => $args->{order_id},
            txn_type => $args->{txn_type},
        }
    )->single;

    if (! $txn) {
        confess "Could not find transaction by id: $args->{id}";
    }

    foreach my $field qw(status ext_id) {
        $txn->$field( $args->{$field} ) if exists $args->{$field};
    }
    $txn->update;
}

sub change_txn_status {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get(schema => 'master');
    $schema->txn_do( \&__change_txn_status, $self, $schema, $args );
}

sub __match_txn {
    my ($self, $schema, $args) = @_;

    my $txn = $schema->resultset('PaymentTransaction')->search(
        {
            order_id => $args->{order_id},
            id => $args->{txn_id},
        }
    )->single;

    my $order;
    if ($txn) {
        $order = $self->find($txn->order_id);
    }
    return $order || ();
}

sub match_txn {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get(schema => 'master');
    $schema->txn_do( \&__match_txn, $self, $schema, $args );
}

1;

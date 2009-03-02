
package Pixis::API::Payment::Transaction;
use Moose;
use namespace::clean -except => qw(meta);

with 'Pixis::API::Base::DBIC';

__PACKAGE__->meta->make_immutable;

sub _build_resultset_moniker {
    return "PaymentTransaction"
}

sub change_status {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get(schema => 'master');
    $schema->txn_do( sub {
        my ($schema, $args) = @_;

        my $txn = $self->find($args->{txn_id});
        my $old = $txn->status;
        my $new = $args->{status};
        $txn->status( $new );

        $txn->create_related( 'PaymentTransactionLog', {
            message    => "change status from $old to $new" .
                ($args->{message} ? ": $args->{message}" : ''),
            created_on => \'NOW()'
        } );

    }, $schema, $args);
}

1;
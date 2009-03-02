
package Pixis::Schema::Master::PaymentTransactionLog;
use strict;
use warnings;
use base qw(Pixis::Schema::Base::MySQL);

__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime", "Core");
__PACKAGE__->table("pixis_payment_transaction_log");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "INTEGER",
        is_auto_increment => 1,
        is_nullable => 0,
        size => 8,
    },
    txn_id => { # 
        data_type => "TEXT",
        is_nullable => 0,
    },
    message => {
        data_type => "TEXT",
    },
    created_on => {
        data_type => "DATETIME",
        is_nullable => 0,
    },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to('txn_id' => 'Pixis::Schema::Master::PaymentTransaction');

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->add_index(
        name => 'txn_id_idx',
        fields => [ 'txn_id(255)' ],
    );
    $sqlt_table->drop_constraint('fk_txn_id');
    $self->next::method($sqlt_table);
}

1;
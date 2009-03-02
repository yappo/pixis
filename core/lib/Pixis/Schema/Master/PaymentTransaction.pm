
package Pixis::Schema::Master::PaymentTransaction;
use strict;
use warnings;
use base qw(Pixis::Schema::Base::MySQL);
use DateTime;

__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime", "Core");
__PACKAGE__->table("pixis_payment_transaction");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "INTEGER",
        is_auto_increment => 1,
        is_nullable => 0,
        size => 8,
    },
    member_id => {
        data_type => "INTEGER",
        is_nullabe => 0,
        size => 8,
    },
    txn_type => {
        data_type => "CHAR",
        size      => 32,
        is_nullable => 0
    },
    txn_id => { # 
        data_type => "TEXT",
        is_nullable => 0,
    },
    amount => {
        data_type => "INTEGER",
        is_nullable => 0,
        size => 8
    },
    status => {
        data_type => "CHAR",
        is_nullable => 0,
        size => 32,
        default_value => "CREATED"
    },
    description => {
        data_type => "TEXT",
        is_nullable => 0
    },
    modified_on => {
        data_type => "TIMESTAMP",
        is_nullable => 0,
        default_value => \'NOW()',
    },
    created_on => {
        data_type => "DATETIME",
        is_nullable => 0,
    },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->has_many('logs' => 'Pixis::Schema::Master::PaymentTransactionLog' => 'txn_id');

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->add_index(
        name => 'txn_type_idx',
        fields => [ 'txn_type(32)' ],
    );
    $sqlt_table->add_index(
        name => 'txn_id_idx',
        fields => [ 'txn_id(255)' ],
    );
    $sqlt_table->add_index(
        name => 'member_id_idx',
        fields => [ 'member_id' ],
    );
    $self->next::method($sqlt_table);
}

1;
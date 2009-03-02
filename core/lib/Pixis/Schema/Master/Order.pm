
package Pixis::Schema::Master::Order;
use strict;
use warnings;
use base qw(Pixis::Schema::Base::MySQL);

use constant ST_UNPAID      => 0;
use constant ST_TXN_PENDING => 1;
use constant ST_PAID        => 2;

__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime", "Core");
__PACKAGE__->table("pixis_order");
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
    amount => {
        data_type => "INTEGER",
        is_nullable => 0,
        size => 8
    },
    status => { # 0 -> new (unpaid), 1 - some sort of transaction pending, 2 - paid
        data_type => "SMALLINT",
        is_nullable => 0,
        default_value => ST_UNPAID,
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
        name => 'member_id_idx',
        fields => [ 'member_id' ],
    );
    $self->next::method($sqlt_table);
}

1;

package Pixis::Schema::Master::JPAPaymentHistory;
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime", "Core");
__PACKAGE__->table("pixis_jpa_payment_history");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "INTEGER",
        is_auto_increment => 1,
        is_nullable => 0,
        size => 32,
    },
    member_id => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 255,
    },
    item_id => {
        data_type => "INTEGER",
        is_nullable => 0,
        size => 8,
    },
    amount => {
        data_type => "INTEGER",
        is_nullable => 0,
        size => 8
    },
    payment_method => { # TBD(null), Paypal, Bank Transfer
        data_type => "VARCHAR",
        is_nullable => 1,
        size => 256
    },
    payment_received_on => {
        data_type => "DATETIME",
        is_nullable => 1,
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

sub populate_initial_data {
    my ($class, $schema) = @_;

}

1;
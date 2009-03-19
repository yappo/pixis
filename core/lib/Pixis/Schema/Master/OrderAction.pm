
package Pixis::Schema::Master::OrderAction;
use strict;
use base qw(Pixis::Schema::Base::MySQL);

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("pixis_order_action");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "INTEGER",
        is_auto_increment => 1,
        is_nullable => 0,
        size => 8,
    },
    order_id => {
        data_type => "CHAR",
        is_nullable => 0,
        size => 12,
    },
    message => {
        data_type => "TEXT",
        is_nullable => 0
    },
    created_on => {
        data_type => "TIMESTAMP",
        is_nullable => 0,
        default_value => \"NOW()"
    },
);

__PACKAGE__->set_primary_key("id");

1;

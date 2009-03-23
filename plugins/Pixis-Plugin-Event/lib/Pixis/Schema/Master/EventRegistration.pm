
package Pixis::Schema::Master::EventRegistration;
use strict;
use warnings;
use base qw(Pixis::Schema::Base::MySQL);

__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime", "UTF8Columns", "Core");
__PACKAGE__->table("pixis_event_registration");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "INTEGER",
        is_auto_increment => 1,
        is_nullable => 0,
        size => 8,
    },
    "event_id" => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 32
    },
    "member_id" => {
        data_type => "INTEGER",
        is_nullable => 0,
        size => 32,
    },
    is_active => {
        data_type => 'TINYINT',
        is_nullable => 0,
        default_value => 0,
        size => 1,
    },
    order_id => {
        data_type => "CHAR",
        is_nullable => 1,
        size => 12,
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
__PACKAGE__->add_unique_constraint([ qw(event_id member_id) ]);

1;

package Pixis::Schema::Master::EventDate;
use strict;
use warnings;
use base qw(Pixis::Schema::Base::MySQL);

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("pixis_event_date");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "INTEGER",
        is_nullable => 0,
        is_auto_increment => 1,
        size => 8,
    },
    "event_id" => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 32
    },
    "date" => {
        data_type => "DATE",
        is_nullable => 0,
    },
    "start_on" => {
        data_type => "TIME",
        is_nullable => 0,
        default_value => "09:00"
    },
    "end_on" => {
        data_type => "TIME",
        is_nullable => 0,
        default_value => "21:00"
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

1;
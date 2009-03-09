
package Pixis::Schema::Master::ActivityGithub;
use strict;
use warnings;
use base qw(Pixis::Schema::Base::MySQL);
use DateTime;

__PACKAGE__->load_components("PK::Auto", "UTF8Columns", "InflateColumn::DateTime", "Core");
__PACKAGE__->table("pixis_activity_github");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "INTEGER",
        is_auto_increment => 1,
        is_nullable => 0,
        size => 32,
    },
    entry_id => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 1024,
    },
    link => {
        data_type => "TEXT",
        is_nullable => 0,
    },
    title => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 1024,
        is_nullable => 0,
    },
    content => {
        data_type => "TEXT",
        is_nullable => 0,
    },
    activity_on => {
        data_type => "DATETIME",
        is_nullable => 0,
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
__PACKAGE__->utf8_columns(qw(title content));

__PACKAGE__->set_primary_key("id");

1;
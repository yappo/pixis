
package Pixis::Schema::Master::MemberActivity;
use strict;
use warnings;
use base qw(Pixis::Schema::Base::MySQL);

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("pixis_member_actiity");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "INTEGER",
        is_auto_increment => 1,
        is_nullable => 0,
        size => 32,
    },
    member_id => {
        data_type => "INTEGER",
        is_nullable => 0,
        size => 32,
    },
    activity_id => {
        data_type => "INTEGER",
        is_nullable => 0,
        size => 32,
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
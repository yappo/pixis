# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/Schema/Master/MemberRelationship.pm 101251 2009-02-27T01:11:52.097394Z daisuke  $

package Pixis::Schema::Master::MemberRelationship;
use strict;
use warnings;
use base qw(Pixis::Schema::Base::MySQL);

__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime", "Core");
__PACKAGE__->table("pixis_member_relationship");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "INTEGER",
        is_nullable => 0,
        is_auto_increment => 1,
        size => 32,
    },
    "from_id" => {
        data_type => "INTEGER",
        is_nullable => 0,
        size => 32,
    },
    "to_id" => {
        data_type => "INTEGER",
        is_nullable => 0,
        size => 32,
    },
    "approved" => {
        data_type => "TINYINT",
        is_nullable => 0,
        size => 1,
        default => 0
    },
    modified_on => {
        data_type => "TIMESTAMP",
        is_nullable => 0,
        default_value => \'NOW()',
    },
    created_on => {
        data_type => "DATETIME",
        is_nullable => 0,
    }
);

__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(from_to => [ "from_id", "to_id" ]);

1;
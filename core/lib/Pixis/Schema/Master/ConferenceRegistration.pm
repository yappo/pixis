# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/Schema/Master/ConferenceRegistration.pm 99505 2009-02-03T03:28:19.287739Z daisuke  $

package Pixis::Schema::Master::ConferenceRegistration;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->load_components("PK::Auto", "Core");
__PACKAGE__->table("pixis_conference_registration");
__PACKAGE__->add_columns(
    "conf_id" => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 32
    },
    "member_id" => {
        data_type => "INTEGER",
        is_nullable => 0,
        size => 32,
    },
    "item_id" => {
        # 商品
        data_type => "INTEGER",
        is_nullable => 0
    }
);
__PACKAGE__->set_primary_key("conf_id", "member_id");

1;
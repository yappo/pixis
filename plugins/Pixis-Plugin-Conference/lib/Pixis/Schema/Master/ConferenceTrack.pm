# $Id: /mirror/pixis/Pixis-Plugin-Conference/trunk/lib/Pixis/Schema/Master/ConferenceTrack.pm 101229 2009-02-25T04:05:51.706623Z daisuke  $

package Pixis::Schema::Master::ConferenceTrack;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime", "UTF8Columns", "Core");
__PACKAGE__->table("pixis_conference_track");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "INTEGER",
        is_nullable => 0,
        is_auto_increment => 1,
        size => 32,
    },
    "title" => {
        data_type => "TEXT",
        is_nullable => 0
    },
    "conference_id" => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 64,
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
__PACKAGE__->utf8_columns("title");

1;
# $Id: /mirror/pixis/Pixis-Plugin-Conference/trunk/lib/Pixis/Schema/Master/ConferenceSession.pm 101249 2009-02-26T12:14:35.111407Z daisuke  $

package Pixis::Schema::Master::ConferenceSession;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime", "UTF8Columns", "Core");
__PACKAGE__->table("pixis_conference_session");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "INTEGER",
        is_auto_increment => 1,
        is_nullable => 0,
        size => 8,
    },
    "conference_id" => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 32,
    },
    "track_id" => {
        data_type => "INTEGER",
        is_nullable => 0,
        size => 8,
    },
    "title" => {
        data_type => "TEXT",
        is_nullable => 0
    },
    "description" => {
        data_type => "TEXT",
        is_nullable => 0
    },
    start_on => {
        data_type => "DATETIME",
        is_nullable => 0,
    },
    end_on => {
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
__PACKAGE__->set_primary_key("id");
__PACKAGE__->utf8_columns("title", "description");

1;
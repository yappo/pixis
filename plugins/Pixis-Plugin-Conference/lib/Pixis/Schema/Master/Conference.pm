# $Id: /mirror/pixis/Pixis-Plugin-Conference/trunk/lib/Pixis/Schema/Master/Conference.pm 101272 2009-02-27T05:53:45.238733Z daisuke  $

package Pixis::Schema::Master::Conference;
use strict;
use warnings;
use base qw(Pixis::Schema::Base::MySQL);

__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime", "UTF8Columns", "Core");
__PACKAGE__->table("pixis_conference");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 32,
    },
    "title" => {
        data_type => "TEXT",
        is_nullable => 0
    },
    "description" => {
        data_type => "TEXT",
        is_nullable => 0
    },
    "category1" => {
        data_type => "INTEGER",
        size => 32,
        is_nullable => 0,
    },
    "category2" => {
        data_type => "CHAR",
        size => 4,
        is_nullable => 1,
    },
    start_on => { # actually, DATE, but what the heck
        data_type => "DATETIME",
        is_nullable => 0,
    },
    end_on => { # same as start_on
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

my %CATEGORIES = (
    '0001' => 'Programming / General',
    '0002' => 'Programming / Perl'
);

sub path { return sprintf('/conference/%s', $_[0]->id) }

1;
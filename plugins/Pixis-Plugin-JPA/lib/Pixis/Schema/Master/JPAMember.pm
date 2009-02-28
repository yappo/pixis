
package Pixis::Schema::Master::JPAMember;
use strict;
use warnings;
use base 'DBIx::Class';


__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime", "Core");
__PACKAGE__->table("pixis_jpa_member");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "INTEGER",
        is_auto_increment => 1,
        is_nullable => 0,
        size => 32,
    },
    email => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 256,
    },
    firstname => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 256
    },
    lastname => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 256
    },
    country => {
        data_type => "TEXT",
        is_nullable => 1,
    },
    state   => {
        data_type => "TEXT",
        is_nullable => 1,
    },
    postal_code => { # won't bind to japanese addresses, for now
        data_type => "TEXT",
        is_nullable => 1,
    },
    address1 => { # when requiring addresses, this is required
        data_type => "TEXT",
        is_nullable => 1,
    },
    address2 => { # your town, whatever
        data_type => "TEXT",
        is_nullable => 1,
    },
    address3 => { # building name, room number, etc.
        data_type => "TEXT",
        is_nullable => 1,
    },
    membership_type => {
        data_type => "VARCHAR",
        is_nullable => 1,
        size => 255
    },
    membership_expires_on => {
        data_type => "DATETIME",
        is_nullable => 1,
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
# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/Schema/Master/MemberAuth.pm 101255 2009-02-27T01:43:08.730273Z daisuke  $

package Pixis::Schema::Master::MemberAuth;
use strict;
use warnings;
use base 'DBIx::Class';

__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime", "Core");
__PACKAGE__->table("pixis_member_auth");
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
    auth_type => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 8
    },
    auth_data => {
        data_type => "TEXT",
        is_nullable => 0,
    },
    is_active => {
        data_type => "TINYINT",
        is_nullable => 0,
        default_value => 1,
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
__PACKAGE__->add_unique_constraint(unique_auth_per_user => ["email", "auth_type"]);

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    my ($c) = grep { $_->name eq 'unique_auth_per_user' } $sqlt_table->get_constraints();
    $c->fields([ 'email(255)', 'auth_type(8)' ]);
}

1;
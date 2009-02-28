# $Id$

package Pixis::Schema::Master::JPAMembership;
use strict;
use warnings;
use base qw(DBIx::Class);
use DateTime;

__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime", "Core");
__PACKAGE__->table("pixis_jpa_membership");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "INTEGER",
        is_auto_increment => 1,
        is_nullable => 0,
        size => 32,
    },
    name => {
        data_type => "TEXT",
        is_nullable => 0,
    },
    price => {
        data_type => "INTEGER",
        is_nullable => 0,
        size => 8,
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

sub populate_initial_data {
    my ($class, $schema) = @_;

    my $now = DateTime->now();
    $schema->populate( 
        JPAMembership => [
            [ qw(name price created_on) ],
            [ qw(JPA一般会員 5000), $now ],
            [ qw(JPA学生会員 0), $now ],
        ]
    );
}

1;


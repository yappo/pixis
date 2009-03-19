
package Pixis::Schema::Master::Order;
use strict;
use warnings;
use base qw(Pixis::Schema::Base::MySQL);

use constant ST_DONE           => 0;
use constant ST_INIT           => 1;
use constant ST_CREDIT_CHECK   => 2;
use constant ST_CREDIT_ACCEPT  => 3;
use constant ST_CHECK_REQUIRED => 4;
use constant ST_SYSTEM_ERROR   => 99;

__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime", "Core");
__PACKAGE__->table("pixis_order");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "CHAR",
        is_nullable => 0,
        size => 12,
    },
    member_id => {
        data_type => "INTEGER",
        is_nullabe => 0,
        size => 8,
    },
    amount => {
        data_type => "INTEGER",
        is_nullable => 0,
        size => 8
    },
    status => {
        # 0 -> DONE
        # 1 -> new
        # 2 -> credit check required (if applicable)
        # 3 -> credit ok, pending accept (if applicable)
        # 4 -> requires some sort of manual check,
        #      for example, for students
        # 99 -> system error
        data_type => "SMALLINT",
        is_nullable => 0,
        default_value => ST_INIT,
    },
    description => {
        data_type => "TEXT",
        is_nullable => 0
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

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->add_index(
        name => 'member_id_idx',
        fields => [ 'member_id' ],
    );
    $sqlt_table->add_index(
        name => 'status_idx',
        fields => [ 'status' ],
    );
    
    $self->next::method($sqlt_table);
}

1;
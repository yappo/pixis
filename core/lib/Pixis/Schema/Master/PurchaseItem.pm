
package Pixis::Schema::Master::PurchaseItem;
use strict;
use warnings;
use base qw(Pixis::Schema::Base::MySQL);
use DateTime;

__PACKAGE__->load_components("PK::Auto", "InflateColumn::DateTime", "Core");
__PACKAGE__->table("pixis_purchase_item");
__PACKAGE__->add_columns(
    # これ、多分本当は個数とかそういうの必要なんだけど・・・・
    # 今はとてつもなく面倒くさいのでスキップします
    "id" => {
        data_type => "CHAR",
        is_nullable => 0,
        size => 16,
    },
    store_name => {
        data_type => "CHAR",
        is_nullable => 0,
        size => 8,
    },
    name => {
        data_type => "TEXT",
        is_nullable => 0,
    },
    price => {
        data_type => "INTEGER",
        is_nullable => 0,
        size => 8
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
        name => 'store_name',
        fields => [ 'store_name(8)' ],
    );
    $self->next::method($sqlt_table);
}

1;

package Pixis::Schema::Master::OrderUniqueId;
use strict;
use warnings;
use base qw(Pixis::Schema::Base::MySQL);

__PACKAGE__->load_components(qw(Core));
__PACKAGE__->table('pixis_order_unique_id');
__PACKAGE__->add_columns(
    value => {
        data_type => "CHAR",
        is_nullable => 0,
        size => 8,
    },
    taken_on => {
        data_type => "DATETIME",
        is_nullable => 1
    }
);

__PACKAGE__->set_primary_key('value');

sub populate_initial_data {
    my ($self, $schema) = @_;
    $self->create_unique_keys($schema, 10_000);
}

sub create_unique_keys {
    my ($self, $schema, $howmany) = @_;

    $howmany ||= 1_000;
    $schema->populate(
        OrderUniqueId => [
            [ qw(value) ],
            map { [ $self->create_unique_key(8) ] }
                1..$howmany
        ],
    );
}

my @constituents = sort { 
    my $r = rand();
    $r > 0.66 ? 1 :
    $r > 0.33 ? 0 :
    -1
} (0,2..9,'a'..'k','m','n','p'..'z','A'..'N','P'..'Z');

sub create_unique_key {
    my $self = shift;
    my $count = shift || 8;
    return join('',
        map { $constituents[rand @constituents] } 1..$count);
}

1;

package Pixis::Schema::Master;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_classes;

sub connection {
    my ($self, @args) = @_;

    if (@args < 4) {
        push @args, {};
    }

    if ($args[0] =~ /^dbi:mysql:/) {
        $args[3]->{on_connect_do} ||= [];
        if (! grep { /STRICT_TRANS_TABLE/ } @{$args[3]->{on_connect_do}}) {
            push @{$args[3]->{on_connect_do}}, 'SET sql_mode = "STRICT_TRANS_TABLES"';
        }
    }
    $self->next::method(@args);
}

1;
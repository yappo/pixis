# $Id$

package Pixis::Schema::Base::MySQL;
use strict;
use warnings;
use base qw(DBIx::Class);

__PACKAGE__->mk_classdata('engine' => 'InnoDB');
__PACKAGE__->mk_classdata('charset' => 'UTF8');

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

print <<EOM;
    Running sql_deploy_hook!
EOM

    $sqlt_table->extra->{mysql_table_type} = $self->engine;
    $sqlt_table->extra->{mysql_charset}    = $self->charset;
}

1;

use strict;
use lib "t/lib";
use Test::More (tests => 1);
use Test::Pixis;
use Pixis::CLI::SetupDB;

my $t = Test::Pixis->instance();

my $connect_info = $t->config->{'Schema::Master'}->{connect_info};

Pixis::CLI::SetupDB->new(
    dsn => $connect_info->[0],
    username => $connect_info->[1],
    password => $connect_info->[2] || '',
    drop => 1,
)->run();

ok(1);
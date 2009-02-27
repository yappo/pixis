use strict;
use Test::More (tests => 6);

BEGIN {
    use_ok "Pixis::Registry";
}

{
    my $registry = Pixis::Registry->instance;
    my $value = time();
    ok( ! $registry->get(foo => bar => 'baz'), "undefined registry");
    ok( $registry->set(foo => bar => baz => $value), "set works" );
    is( $registry->get(foo => bar => 'baz'), $value, "defined registry");
}

{
    my $value = time();
    ok( Pixis::Registry->set(foo => bar => baz => $value), "set works" );
    is( Pixis::Registry->get(foo => bar => 'baz'), $value, "defined registry");
}


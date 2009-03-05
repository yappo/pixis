use strict;
use lib "t/lib";
use Test::More (tests => 18);
use Test::Pixis;
use Test::Exception;

BEGIN
{
    use_ok("Pixis::API::Member");
    use_ok("Pixis::Schema::Master");
}

my $t = Test::Pixis->instance;
my $api = $t->make_api('Member');

{
    my $registry = Pixis::Registry->instance();

    $registry->set(schema => 'master', $t->make_schema('Master'));
}

{
    my $member;
    my %data = (
        email     => 'test@perlassociation.org',
        nickname  => 'testuser',
        firstname => '太郎',
        lastname  => 'テスト',
        password  => 'testing',
        activation_token => Digest::SHA1::sha1_hex($$, rand(), time()),
    );

    lives_ok {
        $member = $api->create(\%data);
        $data{id} = $member->id;
    } "member creation";

    # first time around is_active is false, so all these tests should fail
    my $expected_load_failure = sub {
        my $found = $api->find($data{id});
        ok(! $found, "non active member should not be loaded by pk");
        $found = undef;
        $found = $api->load_from_email($data{email});
        ok(! $found, "non active member should not be loaded by email");

        my @list = $api->search_members({
            email => $data{email}
        });
        ok( !@list, "non active member should not be loaded from search");
    };

    lives_ok(\&$expected_load_failure, "member load (non-active)");

    lives_ok {
        $api->activate({
            email => $data{email},
            token => 'dummy',
        });
        $expected_load_failure->();

        $api->activate({
            email => $data{email},
            token => $data{activation_token},
        });
    } "member activation";

    lives_ok {
        my $found = $api->find($data{id});
        if (ok($found, "member loaded by primary key ok")) {
            is($found->email, $data{email}, "email match");
        } else {
            fail("email match skipped (no member loaded)");
        }

        $found = undef;
        $found = $api->load_from_email($data{email});
        if (ok($found, "member loaded by email ok")) {
            is($found->id, $data{id}, "id match");
        } else {
            fail("id match skipped (no member loaded)");
        }

        my @list = $api->search_members({
            email => $data{email}
        });
        if (is(scalar @list, 1, "search member turns up 1 result")) {
            is($list[0]->email, $data{email}, "email matches");
        } else {
            fail("nothing turned up from search");
        }
    } "member load";

}


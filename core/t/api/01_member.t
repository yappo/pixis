use strict;
use lib "t/lib";
use Test::More (tests => 17);
use Test::Pixis;
use Test::Exception;

BEGIN
{
    use_ok("Pixis::API::Member");
    use_ok("Pixis::Schema::Master");
}

my $t = Test::Pixis->instance;
my $api = $t->make_api('Member');
my %MEMBER1 = (
    email     => 'taro-test@perlassociation.org',
    nickname  => 'testtaro',
    firstname => '太郎',
    lastname  => 'テスト',
    password  => 'testing',
    activation_token => Digest::SHA1::sha1_hex($$, rand(), time()),
);

my %MEMBER2 = (
    email     => 'hanako-test@perlassociation.org',
    nickname  => 'testhanako',
    firstname => '花子',
    lastname  => 'テスト',
    password  => '#$FSOkdi23-$1~',
    activation_token => Digest::SHA1::sha1_hex($$, rand(), time()),
);

{
    my $registry = Pixis::Registry->instance();

    $registry->set(schema => 'master', $t->make_schema('Master'));
    $registry->set(api => 'memberrelationship' => $t->make_api('MemberRelationship'));
}

{
    my $member;

    lives_and {
        $member = $api->create(\%MEMBER1);
        $MEMBER1{id} = $member->id;
    } "member creation";

    # first time around is_active is false, so all these tests should fail
    my $expected_load_failure = sub {
        my $found = $api->find($MEMBER1{id});
        ok(! $found, "non active member should not be loaded by pk");
        $found = undef;
        $found = $api->load_from_email($MEMBER1{email});
        ok(! $found, "non active member should not be loaded by email");

        my @list = $api->search_members({
            email => $MEMBER1{email}
        });
        ok( !@list, "non active member should not be loaded from search");
    };

    lives_and(\&$expected_load_failure, "member load (non-active)");

    lives_and {
        $api->activate({
            email => $MEMBER1{email},
            token => 'dummy',
        });
        $expected_load_failure->();

        $api->activate({
            email => $MEMBER1{email},
            token => $MEMBER1{activation_token},
        });
    } "member activation";

    lives_and {
        my $found = $api->find($MEMBER1{id});
        if (ok($found, "member loaded by primary key ok")) {
            is($found->email, $MEMBER1{email}, "email match");
        } else {
            fail("email match skipped (no member loaded)");
        }

        $found = undef;
        $found = $api->load_from_email($MEMBER1{email});
        if (ok($found, "member loaded by email ok")) {
            is($found->id, $MEMBER1{id}, "id match");
        } else {
            fail("id match skipped (no member loaded)");
        }

        my @list = $api->search_members({
            email => $MEMBER1{email}
        });
        if (is(scalar @list, 1, "search member turns up 1 result")) {
            is($list[0]->email, $MEMBER1{email}, "email matches");
        } else {
            fail("nothing turned up from search");
        }
    } "member load";

    lives_and {
        my $member2 = $api->create(\%MEMBER2);
        if ($member2) {
            $MEMBER2{id} = $member2->id;
        }
        $api->activate({
            email => $MEMBER2{email},
            token => $MEMBER2{activation_token},
        });

        $api->follow($MEMBER1{id}, $MEMBER2{id});

        my @followers = $api->load_followers($MEMBER2{id});
        is (scalar @followers, 1, "people following $MEMBER2{id}");
        if (! is ($followers[0]->id, $MEMBER1{id}, "member 1 is following member 2")) {
            diag( "got followers: ", explain(@followers));
        }
#        my @following = $api->load_following($MEMBER1{id});
#        is (scalar @followers, 1, "1 following $MEMBER2{id}");
        
    }

    lives_and {
        $api->delete($MEMBER1{id});

        my $found = $api->find($MEMBER1{id});
        ok( !$found);

        $found = $api->load_from_email($MEMBER1{email});
        ok( ! $found);
    } "member deletion";
}

END {
    eval {
        $api->delete($MEMBER1{id});
    };
    eval {
        $api->delete($MEMBER2{id});
    }
}


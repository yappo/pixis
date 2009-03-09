
package Pixis::API::Member;
use Moose;
use Pixis::Registry;
use Digest::SHA1();
use namespace::clean -except => qw(meta);

with 'Pixis::API::Base::DBIC';

after 'delete' => sub {
    my ($self, $id) = @_;
    Pixis::Registry->get(api => 'MemberRelationship')->break_all($id);
};

sub _build_resultset_constraints {
    return +{ is_active => 1 }
}

sub load_from_email {
    my ($self, $email) = @_;
    my $member = $self->resultset()->search(
        { email => $email },
        { select => [ qw(id) ] }
    )->first;
    return $member ? $self->find($member->id) : ();
}

sub create {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get(schema => 'master');
    $args->{created_on} ||= DateTime->now;
    my $auth = {
        email => $args->{email},
        auth_type => 'password',
        auth_data => Digest::SHA1::sha1_hex(delete $args->{password}),
        created_on => $args->{created_on}
    };

    my $member;
    $schema->txn_do( sub {
        my $schema = shift;
        $member = $schema->resultset('Member')->create($args);
        $schema->resultset('MemberAuth')->create($auth);
    }, $schema );
    return $member;
}

sub activate {
    my ($self, $args) = @_;

    $args->{token} or die "no token";
    $args->{email} or die "no email";

    my $schema = Pixis::Registry->get(schema => 'master');
    $schema->txn_do( sub {
        my ($self, $args) = @_;
        local $self->{resultset_constraints} = {};
        my $member = $self->resultset()->search({
            is_active => 0,
            activation_token => $args->{token},
            email => $args->{email},
        })->single;
        if ($member) {
            $member->activation_token(undef);
            $member->is_active(1);
            $member->update;
            return $self->find($member->id);
        }
        return ();
    }, $self, $args );
}

sub search_members {
    my ($self, $args) = @_;

    my %where;
    foreach my $param qw(name nickname email) {
        next unless exists $args->{$param};
        my $value = $args->{$param};

        $value =~ s/%/%%/g;
        $where{$param} = { -like => sprintf('%%%s%%', $value) };
    }

    my $schema = Pixis::Registry->get(schema => 'master');
    my $rs     = $self->resultset();
    my @ids = map { $_->id } $rs->search(
        {
            -or => \%where
        },
        {
            select => [ qw(id) ],
        }
    );
    return $self->load_multi(@ids);
}

sub load_following {
    my ($self, $id) = @_;

    my $cache_key = [ 'member', 'following', $id ];
    my @ids = $self->cache_get($cache_key);

    my $schema = Pixis::Registry->get(schema => 'master');
    my $rs     = $schema->resultset('MemberRelationship');
    if (! @ids) {
        @ids = map { $_->to_id } $rs->search(
            {
                from_id => $id,
            },
            {
                select => [ qw(to_id) ],
            }
        );
        $self->cache_set($cache_key, \@ids, 600);
    }

    return $self->load_multi(@ids);
}

sub load_followers {
    my ($self, $id) = @_;

    my $cache_key = [ 'member', 'following', $id ];
    my @ids = $self->cache_get($cache_key);

    my $schema = Pixis::Registry->get(schema => 'master');
    my $rs     = $schema->resultset('MemberRelationship');
    if (! @ids) {
        @ids = map { $_->from_id } $rs->search(
            {
                to_id => $id,
            },
            {
                select => [ qw(from_id) ],
            }
        );
        $self->cache_set($cache_key, \@ids, 600);
    }

    return $self->load_multi(@ids);
}

sub follow {
    my ($self, $from, $to)  = @_;
    Pixis::Registry->get(api => 'MemberRelationship')->follow($from, $to);
}

sub unfollow {
    my ($self, $from, $to)  = @_;
    Pixis::Registry->get(api => 'MemberRelationship')->unfollow($from, $to);
}

__PACKAGE__->meta->make_immutable;
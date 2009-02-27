# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/API/Member.pm 101264 2009-02-27T05:10:06.352581Z daisuke  $

package Pixis::API::Member;
use Moose;
use Pixis::Registry;
use Digest::SHA1();

with 'Pixis::API::Base::DBIC';

__PACKAGE__->meta->make_immutable;

no Moose;

sub load_from_email {
    my ($self, $email) = @_;
    my $member = Pixis::Registry->get(schema => 'master')->resultset('Member')->search(
        { email => $email },
        { select => [ qw(id) ] }
    )->first;
    return $self->find($member->id);
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

sub search_members {
    my ($self, $form) = @_;

    my %where;
    foreach my $param qw(name nickname email) {
        my $value = $form->param($param);
        next unless $value;

        $value =~ s/%/%%/g;
        $where{$param} = { -like => sprintf('%%%s%%', $value) };
    }

    my $cache_key = [ 'member', 'search', \%where ];
    my @ids = $self->cache_get($cache_key);

    my $schema = Pixis::Registry->get(schema => 'master');
    my $rs     = $schema->resultset('Member');
    if (! @ids) {
        @ids = map { $_->id } $rs->search(
            {
                -or => \%where
            },
            {
                select => [ qw(id) ],
            }
        );
        $self->cache_set($cache_key, \@ids, 600);
    }

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

1;
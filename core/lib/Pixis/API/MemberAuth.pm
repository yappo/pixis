package Pixis::API::MemberAuth;
use Moose;
use Pixis::Registry;
use namespace::clean -except => qw(meta);
use Digest::SHA1 ();

with 'Pixis::API::Base::DBIC';

__PACKAGE__->meta->make_immutable;

sub load_auth {
    my ($self, $args) = @_;

    my $cache_key = [ 'pixis', 'member_auth', $args->{email}, $args->{auth_type}];
    my $auth      = $self->cache_get($cache_key);

    if (! $auth) {
        # Find the user that matches tue email
        my $member = Pixis::Registry->get(api => 'member')->load_from_email($args->{email});
        my @ids;
        if ( $member) {
            @ids = map { $_->id } $self->resultset
                ->search({
                    member_id => $member->id,
                    auth_type => $args->{auth_type},
                })
            ;
        }

        if (@ids > 0) {
            $auth = [ $self->load_multi(@ids) ];
            $self->cache_set($cache_key, $auth);
        }
    }
    return defined $auth ? (wantarray ? @$auth : $auth) : ();
}

sub update_auth {
    my ($self, $args) = @_;

    $self->resultset->search(
        {
            member_id => $args->{member_id},
            auth_type => $args->{auth_type},
        }
    )->update(
        {
            auth_data => Digest::SHA1::sha1_hex($args->{password}),
        }
    );

    my $member = Pixis::Registry->get(api => 'member')->find($args->{member_id});
    my $cache_key = [ 'pixis', 'member_auth', $member->email, $args->{auth_type}];

    $self->cache_del($cache_key);
}

1;




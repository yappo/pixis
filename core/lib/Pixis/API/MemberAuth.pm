package Pixis::API::MemberAuth;
use Moose;
use Pixis::Registry;
use namespace::clean -except => qw(meta);

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
            @ids = map { $_->id }
                Pixis::Registry->get(schema => 'master')
                    ->resultset('MemberAuth')->search({
                        member_id => $member->id,
                        auth_type => $args->{auth_tpe},
                    });
        }

        if (@ids > 0) {
            $auth = [ $self->load_multi(@ids) ];
            $self->cache_set($cache_key, $auth);
        }
    }
    return defined $auth ? (wantarray ? @$auth : $auth) : ();
}

1;




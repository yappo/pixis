package Pixis::API::MemberAuth;
use Moose;
use Pixis::Registry;

with 'Pixis::API::Base::DBIC';

no Moose;

sub load_auth {
    my ($self, $args) = @_;

    my $cache_key = [ 'pixis', 'member_auth', $args->{auth_type}, $args->{auth_data} ];
    my $auth      = $self->cache_get($cache_key);

    if (! $auth) {
        my @ids = map { $_->id }
            Pixis::Registry->get(schema => 'master')
                ->resultset('MemberAuth')->search($args);
        if (@ids > 0) {
            $auth = [ $self->load_multi(@ids) ];
            $self->cache_set($cache_key, $auth);
        }
    }
    return defined $auth ? (wantarray ? @$auth : $auth) : ();
}

1;




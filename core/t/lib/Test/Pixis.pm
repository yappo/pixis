
package Test::Pixis;
use MooseX::Singleton;
use Cache::Memcached;
use Config::Any;
use Digest::SHA1 ();

has 'cache' => (
    is => 'rw',
    isa => 'Object',
    lazy_build => 1,
);

has 'config' => (
    is => 'rw',
    isa => 'HashRef',
    lazy_build => 1
);

has 'configfile' => (
    is => 'rw',
    isa => 'Str',
    lazy_build => 1
);

sub _build_cache {
    my $self = shift;
    my $config = $self->config;
    my $cache_config = $config->{'Cache::Memcached'} || {};
    if ($ENV{MEMCACHED_SERVER}) {
        $cache_config->{servers} = [ $ENV{MEMCACHED_SERVER} ];
    }
    $cache_config->{namespace} ||= Digest::SHA1::sha1_hex($<, {}, $$, rand(), time());
    return Cache::Memcached->new($cache_config);
}

sub _build_configfile {
    return $ENV{MYAPP_CONFIG} || 't/conf/pixis_test.yaml';
}

sub _build_config {
    my $self = shift;
    my $filename = $self->configfile;
    my $cfg = Config::Any->load_files({
        files => [ $filename ],
        use_ext => 1,
    });
    return $cfg->[0]->{$filename};
}

sub has_cache {
    my $self = shift;

    return $ENV{MEMCACHED_SERVER} ?  1 : ();

    my $config = $self->config;
    my $cache_config = $config->{'Cache::Memcached'};
    return $cache_config ? 1 : ()
}

sub make_schema {
    my ($self, $type) = @_;

    my $class = "Pixis::Schema::$type";
    my $config_key = "Schema::$type";

    my $config = $self->config;
    Class::MOP::load_class($class);
    return $class->connection(@{$config->{$config_key}->{connect_info}});
}

sub make_api {
    my ($self, $type) = @_;

    my $class = "Pixis::API::$type";
    my $config_key = "Schema::$type";

    my $config = $self->config;
    Class::MOP::load_class($class);

    my $api_config = $config->{$config_key} || {};
    if ($self->has_config) {
        $api_config->{cache} = $self->cache;
    }
    return $class->new(%$api_config);
}

__PACKAGE__->meta->make_immutable;
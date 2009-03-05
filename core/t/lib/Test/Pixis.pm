
package Test::Pixis;
use MooseX::Singleton;
use Config::Any;

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

__PACKAGE__->meta->make_immutable;
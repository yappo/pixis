
package Pixis::API::Base::DBIC;
use Moose::Role;
use MooseX::WithCache;
use namespace::clean -except => qw(meta);

use Moose::Exporter;

Moose::Exporter->setup_import_methods(
    with_caller => [ qw(txn_method) ],
);

has 'resultset_moniker' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
    lazy_build => 1,
);

has 'resultset_constraints' => (
    is => 'rw',
    isa => 'Maybe[HashRef]',
    predicate => 'has_resultset_constraints',
    lazy_build => 1,
);

has 'primary_key' => (
    is => 'rw',
    required => 1,
    lazy_build => 1
);

has 'cache_prefix' => (
    is => 'rw',
    required => 1,
    lazy_build => 1,
);

with_cache 'cache' => (backend => 'Cache::Memcached');

sub _build_resultset_moniker {
    my $self = shift;
    (split(/::/, ref $self))[-1];
}

sub _build_resultset_constraints { +{} }

sub _build_cache_prefix {
    my $self = shift;
    join('.', split(/\./, ref $self));
}

sub resultset {
    my $self = shift;
    my $schema = Pixis::Registry->get('schema' => 'master');
    my $rs     = $schema
        ->resultset($self->resultset_moniker)
        ->search($self->resultset_constraints)
    ;
    return $rs;
}

sub find {
    my ($self, $id) = @_;

    my $cache_key = [$self->cache_prefix, $id ];
    my $obj = $self->cache_get($cache_key);
    if (! $obj) {
        $obj   = $self->resultset->find($id);
        if ($obj) {
            $self->cache_set($cache_key, $obj);
        }
    }
    return $obj;
}

sub load_multi {
    my ($self, @ids) = @_;
    my $schema = Pixis::Registry->get('schema' => 'master');

    # keys is a bit of a hassle
    my $rs = $self->resultset();
    my $h = $self->cache_get_multi(map { [ $self->cache_prefix, $_ ] } @ids);
    my @ret = $h ? values %{$h->{results}} : ();
    foreach my $id ($h ? (map { $_->[2] } @{$h->{missing}}) : @ids) {
        my $conf = $self->find($id);
        push @ret, $conf if $conf;
    }
    return wantarray ? @ret : \@ret;
}

sub _build_primary_key {
    my $self = shift;

    my $schema = Pixis::Registry->get('schema' => 'master');
    my $rs = $self->resultset();

    my @pk = $rs->result_source->primary_columns;
    if (@pk != 1) {
        confess "vanilla Pixis::API::Base::DBIC only supports tables with exactly 1 primary key (" . $self->resultset_moniker . " contains @pk)";
    }

    return $pk[0];
}

sub search {
    my ($self, $where, $attrs) = @_;

    $attrs ||= {};

    my $rs = $self->resultset();
    my $pk = $self->primary_key();

    $attrs->{select} ||= [ $pk ];
    my @keys = map { $_->$pk } $rs->search($where, $attrs);
    return $self->load_multi(@keys);
}

sub create_from_form {
    my ($self, $form) = @_;

    my $schema = Pixis::Registry->get('schema' => 'master');
    local $form->{stash} = { schema => $schema };
    return $form->model->create();
}

sub create {
    my ($self, $args) = @_;
    my $rs = $self->resultset();
    $rs->create($args);
}

sub update {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get('schema' => 'master');

    my $row = $schema->txn_do(sub {
        my ($self, $schema, $args) = @_;
        my $pk = $self->primary_key();
        my $rs = $self->resultset();
        my $key = delete $args->{$pk};
        my $row = $self->find($key);
        if ($row) {
            while (my ($field, $value) = each %$args) {
                $row->$field( $value );
            }
            $row->update;
        }
    }, $self, $schema, $args );
    return $row;
}

sub delete {
    my ($self, $id) = @_;

    my $schema = Pixis::Registry->get('schema' => 'master');
    $schema->txn_do( sub {
        my ($self, $schema, $id) = @_;
        my $obj = $schema->resultset($self->resultset_moniker)->find($id);
        if ($obj) {
            $obj->delete;
        }

        my $cache_key = [$self->cache_prefix, $id ];
        $self->cache_del($cache_key);
    
    }, $self, $schema, $id );
}

sub txn_method {
    my $class = shift;
    my $name  = shift;
    my $schema_name;
    if (! ref $_[0]) {
        $schema_name = shift;
    } else {
        $schema_name = 'Master';
    }
    my $code = shift;
    my $method = Moose::Meta::Method->wrap(
        sub {
            my $schema = Pixis::Registry->get(schema => $schema_name);
            $schema->txn_do($code, @_, $schema);
        },
        package_name => $class,
        name => $name
    );

    if (! defined wantarray ) { # void context
        $class->meta->add_method($name => $method);
    } else {
        return ($name => $code);
    }
}

1;
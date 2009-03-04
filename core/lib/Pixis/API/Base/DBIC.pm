
package Pixis::API::Base::DBIC;
use Moose::Role;
use MooseX::WithCache;
use namespace::clean -except => qw(meta);

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

with_cache 'cache' => (backend => 'Cache::Memcached');

sub _build_resultset_moniker {
    my $self = shift;
    (split(/::/, ref $self))[-1];
}

sub _build_resultset_constraints { +{} }

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

    my $cache_key = ['pixis', ref $self, $id ];
    my $obj = $self->cache_get($cache_key);
    if ($obj) {
        return $obj;
    }

    $obj   = $self->resultset->find($id);
    if ($obj) {
        $self->cache_set($cache_key, $obj);
    }
    return $obj;
}

sub load_multi {
    my ($self, @ids) = @_;
    my $schema = Pixis::Registry->get('schema' => 'master');

    # keys is a bit of a hassle
    my $rs = $self->resultset();
    my $h = $self->cache_get_multi(map { [ 'pixis', ref $self, $_ ] } @ids);
    my @ret = $h ? values %{$h->{results}} : ();
    foreach my $id ($h ? (map { $_->[2] } @{$h->{missing}}) : @ids) {
        my $cache_key = [ 'pixis', ref $self, $id ];
        my $conf = $self->cache_get($cache_key);
        if (! $conf) {
            $conf   = $rs->find($id);
            if ($conf) {
                $self->cache_set($cache_key, $conf);
            }
        }
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

1;
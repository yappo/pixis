
package Pixis::API::Base::DBIC;
use Moose::Role;
use MooseX::WithCache;
use namespace::clean -except => qw(meta);

has 'resultset_moniker' => (
    is => 'rw',
    required => 1,
    lazy_build => 1,
);

with_cache 'cache' => (backend => 'Cache::Memcached');

sub _build_resultset_moniker {
    my $self = shift;
    (split(/::/, ref $self))[-1];
}

sub find {
    my ($self, $id) = @_;

    my $cache_key = ['pixis', ref $self, $id ];
    my $obj = $self->cache_get($cache_key);
    if ($obj) {
        return $obj;
    }

    my $schema = Pixis::Registry->get('schema' => 'master');
    $obj   = $schema->resultset($self->resultset_moniker)->find($id);
    if ($obj) {
        $self->cache_set($cache_key, $obj);
    }
    return $obj;
}

sub load_multi {
    my ($self, @ids) = @_;
    my $schema = Pixis::Registry->get('schema' => 'master');

    # keys is a bit of a hassle
    my $rs = $schema->resultset($self->resultset_moniker);
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

sub search {
    my ($self, $where, $attrs) = @_;

    $attrs ||= {};
    my $schema = Pixis::Registry->get('schema' => 'master');

    my $rs = $schema->resultset($self->resultset_moniker);

    my @pk = $rs->result_source->primary_columns;
    if (@pk != 1) {
        confess "vanilla API::search only supports tables with exactly 1 primary key (" . $self->resultset_moniker . " contains @pk)";
    }

    my ($pk) = @pk;
    $attrs->{select} ||= \@pk;
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
    my $schema = Pixis::Registry->get('schema' => 'master');
    my $rs = $schema->resultset($self->resultset_moniker);
    $rs->create($args);
}

1;
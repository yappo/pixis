# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/API/Base/DBIC.pm 101219 2009-02-25T02:24:11.216454Z daisuke  $

package Pixis::API::Base::DBIC;
use Moose::Role;
use MooseX::WithCache;

has 'resultset_moniker' => (
    is => 'rw',
    required => 1,
    lazy_build => 1,
);

with_cache(backend => 'Cache::Memcached');

no Moose::Role;

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

sub create_from_form {
    my ($self, $form) = @_;

    my $schema = Pixis::Registry->get('schema' => 'master');
    local $form->{stash} = { schema => $schema };
    return $form->model->create();
}

1;
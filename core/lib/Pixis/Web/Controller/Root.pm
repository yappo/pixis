package Pixis::Web::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

__PACKAGE__->config->{namespace} = '';
__PACKAGE__->mk_accessors($_) for qw(site_index);

sub COMPONENT {
    my ($self, $c, $config) = @_;

    $self = $self->NEXT::COMPONENT($c, $config);

    my $site_index = $config->{site_index} || $c->config->{site}->{index};
    $self->site_index($site_index) if $site_index;
    return $self;
}

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    if (my $index = $self->site_index()) {
        # user has define some sort of custom index
        $c->res->redirect($c->uri_for($index));
    }

    if ($c->user_exists) {
        $c->res->redirect($c->uri_for('/member/home'));
        $c->finalize();
    }
}

sub default :Path {
    Pixis::Web::Exception::FileNotFound->throw();
}

sub error :Private {
    my ($self, $c, $comment) = @_;
    Pixis::Web::Exception->new(message => $comment);
}

sub end : ActionClass('RenderView') {}

1;

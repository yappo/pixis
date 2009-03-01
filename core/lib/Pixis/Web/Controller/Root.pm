package Pixis::Web::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';

__PACKAGE__->config->{namespace} = '';

sub index :Path :Args(0) {
    my ($self, $c) = @_;

    if ($c->user_exists) {
        $c->res->redirect($c->uri_for('/member/home'));
        $c->finalize();
    }
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

sub error :Private {
    my ($self, $c, $comment) = @_;
    $c->response->body($comment);
    $c->response->status(500);
}

sub end : ActionClass('RenderView') {}

1;

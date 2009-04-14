# $Id$

package Pixis::Web::Controller::Admin::JPA::Member;
use strict;
use base qw(Pixis::Web::Controller::Admin Catalyst::Controller::HTML::FormFu);

sub index :Index :Args(0) {}

sub list :Local :Args(0) :FormConfig {
    my ($self, $c) = @_;

    my $list;
    my $form = $c->stash->{form};
    if ($form->submitted) {
        if (! $form->valid) {
            $form->force_error_message(1);
        } else {
            my %params = %{$form->params};
            my $attrs = {};
            delete $params{submit};
            delete $params{view};
            foreach my $field qw(limit page offset) {
                next unless exists $params{$field};
                $attrs->{$field} = delete $params{$field};
            }
            $list = $c->registry(api => 'JPAMember')->search(\%params, $attrs);
        }
    } else {
        $list = $c->registry(api => 'JPAMember')->search(undef, { limit => 20, page => 1 });
    }
    $c->stash->{list} = $list;

    my $view = $form->param("view") || 'HTML';
    if ($view eq 'HTML') {
        $c->forward('View::TT');
    } elsif ($view eq 'CSV') {
        my $csv = [
            map { [
                join(' ', $_->lastname, $_->firstname),
                $_->member_id,
                $_->is_active
            ] } @$list
        ];
        $c->stash->{csv} = { data => $csv };
        $c->forward('View::CSV');
    } else {
        $c->forward('View::TT');
    }
}

sub load_member :Chained :PathPart("admin/jpa/member") CaptureArgs(1) {
    my ($self, $c, $jpa_member_id) = @_;

    $c->stash->{jpa_member} = $c->registry(api => 'JPAMember')->find($jpa_member_id);
    $c->stash->{member} = $c->registry(api => 'Member')->find(
        $c->stash->{jpa_member}->member_id
    );
}

sub view :Chained("load_member") :PathPart('') :Args(0) {}

sub disable :Chained("load_member") :Args(0) {
    my ($self, $c) = @_;

    $c->registry(api => 'JPAMember')->deactivate({
        jpa_member_id => $c->stash->{jpa_member}->id
    });
    $c->stash->{jpa_member}->is_active(0);
    $c->res->redirect($c->uri_for('/admin/jpa/member', $c->stash->{jpa_member}->id));
}

sub enable :Chained("load_member") :Args(0) {
    my ($self, $c) = @_;

    $c->registry(api => 'JPAMember')->activate({
        jpa_member_id => $c->stash->{jpa_member}->id
    });
    $c->stash->{jpa_member}->is_active(1);
    $c->res->redirect($c->uri_for('/admin/jpa/member', $c->stash->{jpa_member}->id));
}

1;
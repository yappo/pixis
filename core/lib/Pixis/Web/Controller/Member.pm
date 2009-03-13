# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/Web/Controller/Member.pm 101219 2009-02-25T02:24:11.216454Z daisuke  $

package Pixis::Web::Controller::Member;
use strict;
use warnings;
use base qw(Catalyst::Controller::HTML::FormFu);

sub auto :Private {
    my ($self, $c) = @_;

    $c->forward('/auth/assert_logged_in') or return;

}

sub load_member :Chained :PathPart('member') CaptureArgs(1) {
    my ($self, $c, $id) = @_;

    my $api = $c->registry(api => 'Member');
    my $member = $api->find($id);
    if (! $member) {
        $c->forward('/default');
        return;
    }
    $c->stash->{member} = $member;

    $c->stash->{following} = $api->load_following($id);
    $c->stash->{followers} = $api->load_followers($id);
}

sub home :Local {
    # XXX Later?
    my($self, $c) = @_;
    $c->res->redirect($c->uri_for($c->user->id));
}

sub view :Chained('load_member') :PathPart('') Args(0) {
    my ($self, $c) = @_;

    # Load my latest activities


}

# XXX - follow status
sub follow :Chained('load_member') :Args(0) {
    my ($self, $c) = @_;

    $c->forward('/auth/assert_logged_in') or return;
    $c->registry(api => 'Relationship')->follow($c->user, $c->stash->{member});
}

sub unfollow :Chained('load_member') :Args(0) {
    my ($self, $c) = @_;
    $c->forward('/auth/assert_logged_in') or return;
    $c->registry(api => 'Relationship')->unfollow($c->user, $c->stash->{member});
}

sub settings :Local :Args(0) {}

sub settings_basic :Path('settings/basic') :Args(0) :FormConfig {
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    my $user = $c->registry(api => 'Member')->find($c->user->id);
    $form->model->default_values($user);
    if ($form->submitted_and_valid) {
        $c->registry(api => 'Member')->update_from_form($user, $form);
        if ($c->user->email ne $user->email) {
            # XXX - Hack to overcome Catalyst::Plugin::Authentication
            $c->session->{__user} = { $user->get_columns };
        }
        $c->res->redirect($c->uri_for('home'));
    }
}

sub search :Local :Args(0) :FormConfig {
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        $c->stash->{members} = $c->registry(api => 'Member')->search_members($form->params);
    }
}

sub leave :Local :Args(0) :FormConfig {
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        $c->stash->{template} = 'member/leave_confirm.tt';
        $form->action('/member/leave/commit');
    }
}

sub leave_commit :Path('leave/commit') :Args(0) :FormConfig {
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        $c->registry(api => 'Member')->soft_delete($c->user->id);
        $c->logout;
        $c->res->redirect($c->uri_for('/'));
        return;
    }

    # why would you get here?!
    $c->res->redirect($c->uri_for('/member/leave'));
}

1;
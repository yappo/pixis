# $Id$

package Pixis::Web::Controller::Admin::JPA::Member;
use strict;
use base qw(Pixis::Web::Controller::Admin Catalyst::Controller::HTML::FormFu);

sub index :Index :Args(0) {}

sub list :Local :Args(0) :FormConfig {
    my ($self, $c) = @_;

    my $list;
    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        my $params = $form->params;
        my $attrs = {};
        foreach my $field qw(limit page offset) {
            next unless exists $params->{$field};
            $attrs->{$field} = $params->{$field};
        }
        $list = $c->registry(api => 'JPAMember')->search($params, $attrs);
    } else {
        $list = $c->registry(api => 'JPAMember')->search(undef, { limit => 20, page => 1 });
    }
use Data::Dumper;
warn Dumper($list);
    $c->stash->{list} = $list;
}

1;

package Pixis::Web::Controller::Event;
use strict;
use warnings;
use base qw(Catalyst::Controller::HTML::FormFu);

sub index :Index :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{conferences} = 
        $c->registry(api => 'Event')->load_coming(
            { max => DateTime->now(time_zone => 'local')->add(years => 1) });
}

sub create :Local :FormConfig :PixisPriv('admin') {
    my ($self, $c) = @_;

    $c->forward('/auth/assert_roles', ['admin']);
    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        $form->add_valid(created_on => DateTime->now);
        my $conference = eval {
            $c->registry(api => 'Event')->create_from_form($c->stash->{form});
        };

        if ($@) {
            $c->res->body("Creation failed: $@");
            return;
        }
        return $c->res->redirect($conference->path);
    }
}

sub load_conference :Chained :PathPart('conference') :CaptureArgs(1) {
    my ($self, $c, $id) = @_;

    $c->stash->{conference} = 
        eval { $c->registry(api => 'Event')->find($id) };
    if ($@) {
        $c->log->error("Error at load_conference: $@");
    }
    if (! $c->stash->{conference}) {
        $c->forward('/default');
        $c->finalize();
    }

    $c->stash->{tracks} = 
        $c->registry(api => 'Event')->load_tracks($id);
}

sub view :Chained('load_conference') :PathPart('') :Args(0) {
}

sub edit :Chained('load_conference') :PathPart('edit') :Args(0) :FormConfig {
    my ($self, $c) = @_;

    $c->forward('/auth/assert_roles', ['admin']) or return;
    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        $form->model->update($c->stash->{conference});
    } else {
        $form->model->default_values($c->stash->{conference});
    }
}

sub attendees :Chained('load_conference') :Args(0) {
}

sub register :Chained('load_conference') :Args(0) {
    my ($self, $c) = @_;

    $c->user or $c->res->redirect('/login');
}

1;

package Pixis::Web::Controller::Event;
use strict;
use warnings;
use base qw(Catalyst::Controller::HTML::FormFu);

sub index :Index :Args(0) {
    my ($self, $c) = @_;

    $c->stash->{events} = 
        $c->registry(api => 'Event')->load_coming(
            { max => DateTime->now(time_zone => 'local')->add(years => 1) });
}

sub create :Local :FormConfig :PixisPriv('admin') {
    my ($self, $c) = @_;

    $c->forward('/auth/assert_roles', ['admin']);
    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        $form->add_valid(created_on => DateTime->now);
        my $event = eval {
            $c->registry(api => 'Event')->create_from_form($c->stash->{form});
        };

        if ($@) {
            $c->res->body("Creation failed: $@");
            return;
        }
        return $c->res->redirect($c->uri_for('/event/' . $event->id));
    }
}

sub load_event :Chained :PathPart('event') :CaptureArgs(1) {
    my ($self, $c, $id) = @_;

    $c->stash->{event} = 
        eval { $c->registry(api => 'Event')->find($id) };
    if ($@) {
        $c->log->error("Error at load_event: $@");
    }
    if (! $c->stash->{event}) {
        $c->forward('/default');
        $c->finalize();
    }

    $c->stash->{tracks} = 
        $c->registry(api => 'Event')->load_tracks($id);
}

sub view :Chained('load_event') :PathPart('') :Args(0) {
}

sub edit :Chained('load_event') :PathPart('edit') :Args(0) :FormConfig {
    my ($self, $c) = @_;

    $c->forward('/auth/assert_roles', ['admin']) or return;
    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        $form->model->update($c->stash->{event});
    } else {
        $form->model->default_values($c->stash->{event});
    }
}

sub attendees :Chained('load_event') :Args(0) {
}

sub register :Chained('load_event') :Args(0) {
    my ($self, $c) = @_;

    $c->user or $c->res->redirect('/login');
}

1;
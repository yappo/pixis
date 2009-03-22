
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
        $form->param('end_on')->add(days => 1)->subtract(seconds => 1);
        $form->param('registration_end_on')->add(days => 1)->subtract(seconds => 1);
        my $event = eval {
            $c->registry(api => 'Event')->create_from_form($c->stash->{form});
        };
        if ($@) {
            if ($@ =~ /Duplicate entry/) {
                $form->form_error_message("Event ID " . $form->param('id') . " already exists");
                $form->force_error_message(1);
            } else {
                $c->res->body("Creation failed: $@");
            }
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
    my $event = $c->stash->{event};
    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        $form->model->update($event);
        $c->res->redirect($c->uri_for('/event', $event->id));
        return;
    } else {
        $form->model->default_values($event);

        my @dates;
        foreach my $date ($c->registry(api => 'Event')->get_dates({ event_id => $event->id })) {
            my $f = $self->form();
            $f->load_config_file('event/date.yml');
            $f->action($c->uri_for('/event', $event->id, 'date', $date->date));
            $f->model->default_values($date);
            push @dates, $f;
        }
        $c->stash->{dates} = \@dates;
    }
}

sub attendees :Chained('load_event') :Args(0) {
}

sub register :Chained('load_event') :Args(0) :FormConfig {
    my ($self, $c) = @_;

    $c->forward('/auth/assert_logged_in') or return;

    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        my $event = $c->stash->{event};
        my $api = $c->registry(api => 'Event');
        if (! $api->is_registration_open({ event_id => $event->id }) ) {
            $c->error("stop");
            $c->detach('');
        }
        if (! $api->is_registered({ event_id => $event->id, member_id => $c->user->id })) {
            $api->register({
                event_id => $c->stash->{event}->id,
                member_id => $c->user->id
            });
        }
        $c->res->redirect('/event', $event->id, 'registered');
        return;
    }
}

sub registered :Chained('load_event') :Args(0) {
}
1;
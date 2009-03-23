
package Pixis::Web::Controller::Event::Track;
use strict;
use base qw(Catalyst::Controller::HTML::FormFu);

sub load_track :Chained('/event/load_event')
               :PathPart('track')
               :CaptureArgs(1)
{
    my ($self, $c, $track_id) = @_;
    $c->stash->{track} = 
        $c->registry(api => 'EventTrack')->find(
            $track_id,
        )
    ;

    # sanity check
    if ($c->stash->{track}->event_id ne $c->stash->{event}->id) {
        $c->detach('/default');
    }
}

sub add :Chained('/event/load_event')
        :PathPart('track/add') 
        :FormConfig
        :Args(0)
{
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        my $event = $c->stash->{event};
        $form->add_valid(created_on => DateTime->now(time_zone => 'local'));
        $form->add_valid(event_id => $event->id);
        $c->registry(api => 'EventTrack')->create_from_form($form);
        $c->res->redirect($c->uri_for('/event', $event->id));
    }
}

sub view :Chained('load_track')
         :Args(0)
         :PathPart('')
{
}

1;
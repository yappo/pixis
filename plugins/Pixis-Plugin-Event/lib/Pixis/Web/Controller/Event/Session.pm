
package Pixis::Web::Controller::Event::Session;
use strict;
use base qw(Catalyst::Controller::HTML::FormFu);
use DateTime::Format::Duration;

sub load_event :Chained('/event/load_event') 
               :PathPart('session')
               :CaptureArgs(1)
{
    my ($self, $c, $session_id) = @_;

    # hmm, may need to check session.event_id = event.id
    $c->stash->{session} = $c->registry(api => 'EventSession')->find($session_id)
}

sub add :Chained('/event/track/load_track')
        :PathPart('session/add')
        :Args(0)
        :FormConfig
{
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        $form->add_valid(event_id => $c->stash->{event}->id);
        $form->add_valid(track_id      => $c->stash->{track}->id);
        $form->add_valid(end_on        => $form->param('start_on') + DateTime::Duration->new(minutes => $form->param('duration')) );
        $form->add_valid(created_on    => \'NOW()');
        eval {
            $c->registry(api => 'EventSession')->create_from_form($form);
        };
        if (my $e = $@) {
            if ($e =~ /Selected timeslot conflicts with another session/) {
                $form->form_error_message(
                    $c->localize("Selected timeslot conflicts with another session") );
            } else {
                $form->form_error_message($e);
            }
            $form->force_error_message(1);
        } else {
            $c->res->redirect(
                $c->uri_for('/event', $c->stash->{event}->id, 'track', $c->stash->{track}->id));
        }
    }
}

my $dur_format = DateTime::Format::Duration->new(
    pattern => '%s'
);
sub list :Chained('/event/track/load_track')
        :PathPart('session/list')
        :Args(0)
{
    my ($self, $c) = @_;
    $c->stash->{json} = [ map { 
        my $start_on = $_->start_on;
        my $end_on   = $_->end_on;
        {
            id => $_->id,
            title => $_->title,
#            start_on => $start_on->strftime('%Y-%m-%d %H:%M'),
            end_on   => $end_on->strftime('%Y-%m-%d %H:%M'),
            start_on => $dur_format->format_duration($start_on - $start_on->clone->truncate(to => 'day')),
            duration => $dur_format->format_duration($_->end_on - $_->start_on),
        }
    }
        $c->registry(api => 'EventSession')->load_from_track( {
            event_id => $c->stash->{event}->id,
            track_id      => $c->stash->{track}->id,
        } )
    ] ;
    $c->forward('View::JSON');
}

sub view :Chained('load_event')
         :PathPart('')
         :Args(0)
{
}

1;

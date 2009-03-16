# $Id: /mirror/pixis/Pixis-Plugin-Conference/trunk/lib/Pixis/Web/Controller/Conference/Session.pm 101273 2009-02-27T05:53:53.620525Z daisuke  $

package Pixis::Web::Controller::Conference::Session;
use strict;
use base qw(Catalyst::Controller::HTML::FormFu);
use DateTime::Format::Duration;

sub add :Chained('/conference/track/load_track')
        :PathPart('session/add')
        :Args(0)
        :FormConfig
{
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        $form->add_valid(conference_id => $c->stash->{conference}->id);
        $form->add_valid(track_id      => $c->stash->{track}->id);
        $form->add_valid(end_on        => $form->param('start_on') + DateTime::Duration->new(minutes => $form->param('duration')) );
        $form->add_valid(created_on    => DateTime->now);
        eval {
            $c->registry(api => 'ConferenceSession')->create_from_form($form);
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
                $c->uri_for('/conference', $c->stash->{conference}->id, 'track', $c->stash->{track}->id));
        }
    }
}

my $dur_format = DateTime::Format::Duration->new(
    pattern => '%s'
);
sub list :Chained('/conference/track/load_track')
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
        $c->registry(api => 'ConferenceSession')->load_from_track( {
            conference_id => $c->stash->{conference}->id,
            track_id      => $c->stash->{track}->id,
        } )
    ] ;
    $c->forward('View::JSON');
}
1;

# $Id: /mirror/pixis/Pixis-Plugin-Conference/trunk/lib/Pixis/Web/Controller/Conference/Track.pm 101249 2009-02-26T12:14:35.111407Z daisuke  $

package Pixis::Web::Controller::Conference::Track;
use strict;
use base qw(Catalyst::Controller::HTML::FormFu);

sub load_track :Chained('/conference/load_conference')
               :PathPart('track')
               :CaptureArgs(1)
{
    my ($self, $c, $track_id) = @_;
    $c->stash->{track} = 
        $c->registry(api => 'ConferenceTrack')->find(
            $track_id,
        )
    ;

    # sanity check
    if ($c->stash->{track}->conference_id ne $c->stash->{conference}->id) {
        $c->detach('/default');
    }
}

sub add :Chained('/conference/load_conference')
        :PathPart('track/add') 
        :FormConfig
        :Args(0)
{
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        my $conference = $c->stash->{conference};
        $form->add_valid(created_on => DateTime->now);
        $form->add_valid(conference_id => $conference->id);
        $c->registry(api => 'ConferenceTrack')->create_from_form($form);
        $c->res->redirect($c->uri_for('/conference', $conference->id));
    }
}

sub view :Chained('load_track')
         :Args(0)
         :PathPart('')
{
}

1;
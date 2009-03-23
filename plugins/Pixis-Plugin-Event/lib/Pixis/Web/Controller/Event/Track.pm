
package Pixis::Web::Controller::Event::Track;
use strict;
use base qw(Catalyst::Controller::HTML::FormFu);
use DateTime::Format::Strptime;

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

sub view_default :Chained('load_track')
                 :Args(0)
                 :PathPart('')
{
    my ($self, $c) = @_;

    my @dates = Pixis::Registry->get(api => 'EventDate')->load_from_event(
        $c->stash->{event}->id
    );
    $c->res->redirect($c->uri_for('/event', $c->stash->{event}->id, 'track', $c->stash->{track}->id, $dates[0]->date));
}

my $fmt = DateTime::Format::Strptime->new(pattern => '%Y-%m-%d', time_zone => 'local');
sub view :Chained('load_track')
         :Args(1)
         :PathPart('')
{
    my ($self, $c, $date) = @_;

    $c->stash->{date} = $fmt->parse_datetime($date);
    my $d = Pixis::Registry->get(api => 'EventDate')->load_from_event_date({ event_id => $c->stash->{event}->id, date => $date });
    $d->start_on =~ /^(\d+)/;
    $c->stash->{start_hour} = int( $1 );
    $d->end_on =~ /^(\d+)/;
    $c->stash->{end_hour} = int( $1 );
}

1;
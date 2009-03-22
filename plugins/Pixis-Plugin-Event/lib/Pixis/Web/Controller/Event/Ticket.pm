package Pixis::Web::Controller::Event::Ticket;
use strict;
use base qw(Catalyst::Controller::HTML::FormFu);

sub create :Chained('/event/load_event')
           :PathPart('ticket/create')
           :Args(0)
           :FormConfig
{
    my ($self, $c) = @_;

    my $form = $c->stash->{form};
    if ($form->submitted_and_valid) {
        $form->add_valid(event_id => $c->stash->{event}->id);
        $form->add_valid(created_on => \'NOW()');
        $c->registry(api => 'EventTicket')->create_from_form($form);
        $c->res->redirect($c->uri_for('/event', $c->stash->{event}->id));
        return;
    }
}

1;
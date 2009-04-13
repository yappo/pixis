# $Id$

package Pixis::API::Event;
use Moose;
use Pixis::API::Base::DBIC;
use POSIX qw(strftime);
use namespace::clean -except => qw(meta);

with 'Pixis::API::Base::DBIC';

around(__PACKAGE__->txn_method(create => sub {
    my ($next, $self, $args) = @_;

    my $event = $next->($self, $args);
    Pixis::Registry->get(api => 'EventTrack')->create({
        event_id => $event->id,
        title    => 'Track 1'
    });
    my $event_date_api = Pixis::Registry->get(api => 'EventDate');
    my $cur = $event->start_on->clone;
    my $end = $event->end_on;
    while ($cur <= $end) {
        $event_date_api->create({
            event_id => $event->id,
            date => $cur->strftime('%Y/%m/%d'),
            created_on => \'NOW()',
        });
        $cur->add(days => 1);
    }
    return $event;
}));

around(__PACKAGE__->txn_method(create_from_form => sub {
    my ($next, $self, $args) = @_;

    my $event = $next->($self, $args);
    Pixis::Registry->get(api => 'EventTrack')->create({
        event_id => $event->id,
        title    => 'Track 1',
        created_on => DateTime->now,
    });
    my $event_date_api = Pixis::Registry->get(api => 'EventDate');
    my $cur = $event->start_on->clone;
    my $end = $event->end_on;
    while ($cur <= $end) {
        $event_date_api->create({
            event_id => $event->id,
            date => $cur->strftime('%Y/%m/%d'),
            created_on => \'NOW()',
        });
        $cur->add(days => 1);
    }
    return $event;
}));

__PACKAGE__->txn_method(add_session => sub {
    my ($self, $args) = @_;

    # If this event doesn't have a track, then create one.
    # The default track will just have a name Track 1
    my $track_api = Pixis::Registry->get(api => 'EventTrack');
    my $track;

    if (my $track_id = $args->{track_id}) {
        $track = $track_api->find($track_id);
    } else {
        $track = $track_api->load_or_create_default_track($args);
    }

    $track_api->add_session(
        {
            %$args,
            track_id => $track->id,
        }
    );
});

sub load_tracks {
    Pixis::Registry->get(api => 'EventTrack')->load_from_event($_[1]);
}

sub load_sessions {
    my ($self, $args) = @_;

    my $track_api = Pixis::Registry->get(api => 'EventTrack');
    my $track;
    if (my $track_id = $args->{track_id}) {
        $track = $track_api->find($track_id);
    } else {
        $track = $track_api->load_or_create_default_track($args);
    }
    $track_api->load_sessions({ track_id => $track->id });
}

sub load_sessions_from_date {
    my ($self, $args) = @_;

    my $event = $self->find($args->{event_id});
    my $date = $args->{date} || $event->start_on;

    Pixis::Registry->get(api => 'EventSession')
        ->load_from_date({ event_id => $event->id, start_on => $date });
}

sub load_coming {
    my ($self, $args) = @_;

    my @ids = $self->resultset->search(
        { 
            -and => [
                start_on => { '<=' => $args->{max} },
                start_on => { '>'  => strftime('%Y-%m-%d', localtime) },
            ]
        },
        {
            select => [ 'id' ]
        }
    );

    return $self->load_multi(map { $_->id } @ids);
}

sub load_tickets {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get(schema => 'master');
    return $schema->resultset('EventTicket')->search(
        {
            event_id => $args->{event_id},
        },
        {
            rows => 1
        }
    )->single ? 1 : ();
}

sub is_registration_open {
    my ($self, $args) = @_;

    my $event = $self->find($args->{event_id});
    return () if (! $event);

    # Make sure there are tickets registered for this event
    my $count;

    $count = $self->load_tickets({ event_id => $args->{event_id} });
    if ($count <= 0) {
        return ();
    }

    # check how many people have registered
    $count = $self->load_registered_count({ event_id => $args->{event_id} });
    if ($count >= $event->capacity) {
        return ();
    }

    my $now = DateTime->now(time_zone => 'local');
    return $event->is_registration_open &&
        $event->registration_start_on <= $now &&
        $event->registration_end_on >= $now
    ;
}

sub load_registered_count {
    my ($self, $args) = @_;

    my $event = $self->find($args->{event_id});
    return () if (! $event);

    my $schema = Pixis::Registry->get(schema => 'master');
    # XXX we need to cache this
    my $row = $schema->resultset('EventRegistration')->search(
        undef,
        {
            select => [ 'count(*)' ],
            as     => [ 'count' ]
        }
    )->single;
    return $row->get_column('count');
}

sub get_registration_status {
    my ($self, $args) = @_;
    my $schema = Pixis::Registry->get(schema => 'master');
    # XXX we need to cache this
    my ($row) = $schema->resultset('EventRegistration')->search(
        {
            member_id => $args->{member_id},
            event_id  => $args->{event_id},
        },
        {
            rows => 1,
        }
    );

    return () unless $row;

    my $order = Pixis::Registry->get(api => 'Order')->find($row->order_id);
    if ($order) {
        if ($order->amount > 0 && ($order->is_pending_accept || $order->is_pending_credit_check || $order->is_init)) {
            return -1; # registered, but unpaid
        } elsif ($order->is_done) {
            return 1;
        }
    }
    return ();
}

sub is_registered {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get(schema => 'master');
    # XXX we need to cache this
    my ($ok) = $schema->resultset('EventRegistration')->search(
        {
            member_id => $args->{member_id},
            event_id  => $args->{event_id},
        },
        {
            rows => 1,
        }
    );
    return $ok;
}

sub register {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get(schema => 'master');
    my $order = $schema->txn_do( sub { 
        my ($self, $args, $schema) = @_;
        my $event  = $self->find($args->{event_id});
        my $ticket = $schema->resultset('EventTicket')->search(
            {
                id => $args->{ticket_id},
                event_id => $args->{event_id}
            }
        )->single;
        die "Ticket with id $args->{ticket_id} could not be found" unless $ticket;

        my $order_api = Pixis::Registry->get(api => 'Order');
        my $order = $order_api->create( {
            member_id   => $args->{member_id}, # pixis member ID
            amount      => $ticket->price,
            description => sprintf('%s - %s', $event->title, $ticket->name),
            created_on  => \'NOW()',
        });

        $schema->resultset('EventRegistration')->create(
            {
                member_id  => $args->{member_id},
                event_id   => $args->{event_id},
                order_id   => $order->id,
                created_on => \'NOW()',
            },
        );

        return $order;
    }, $self, $args, $schema );
    die "Failed to register" if $@;

    return $order;
}

sub get_dates {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get(schema => 'Master');
    my @dates = $schema->resultset('EventDate')->search(
        {
            event_id => $args->{event_id}
        },
        {
            order_by => 'date ASC'
        }
    );
    return wantarray ? @dates : [@dates];
}


__PACKAGE__->meta->make_immutable;
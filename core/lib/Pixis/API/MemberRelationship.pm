# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/API/MemberRelationship.pm 101256 2009-02-27T02:28:53.275232Z daisuke  $

package Pixis::API::MemberRelationship;
use Moose;
use namespace::clean -except => qw(meta);

with 'Pixis::API::Base::DBIC';

sub follow {
    my ($self, $from, $to) = @_;

    if (blessed $from) {
        $from  = $from->id;
    }

    if (blessed $to) {
        $to = $to->id;
    }

    my $schema = Pixis::Registry->get(schema => 'master');

    # Does the other person have a follow status to me? if so,
    # I say we have feelings for each other
    my $rs = Pixis::Registry->get(schema => 'master')->resultset('MemberRelationship');

    my $there_to_here = $rs->find({from_id => $to, to_id => $from});
    my $here_to_there = $rs->find_or_create(
        from_id  => $from,
        to_id    => $to,
        approved => $there_to_here ? 1 : 0,
        created_on => \'NOW()',
    );
    if ($there_to_here && ! $there_to_here->approved) {
        $there_to_here->approved(1);
        $there_to_here->update;
    }
}

sub unfollow {
    my ($self, $from, $to) = @_;

    if (blessed $from) {
        $from  = $from->id;
    }

    if (blessed $to) {
        $to = $to->id;
    }

    my $schema = Pixis::Registry->get(schema => 'master');
    $schema->txn_do( sub {
        my ($self, $from, $to) = @_;
        my $rs = $self->resultset();

        my $here_to_there = $rs->find({ from_id => $from, to_id => $to });
        if ($here_to_there) {
            $here_to_there->delete;
        }

        # Does the other person have a follow status to me? if so,
        # I say we no longer have feelings for each other
        my $there_to_here = $rs->find({from_id => $to, to_id => $from});
        if ($there_to_here && $there_to_here->approved) {
            $there_to_here->approved(0);
            $there_to_here->update;
        }
    }, $self, $from, $to);
}

sub is_mutual {
    my ($self, $from, $to) = @_;

    my $rs = Pixis::Registry->get(schema => 'master')->resultset('MemberRelationship');
    my $here_to_there = $rs->find({ from_id => $from->id, to_id => $to->id });
    my $there_to_here = $rs->find({from_id => $to->id, to_id => $from->id});
    return ($here_to_there && $there_to_here) ? 1 : ();
}

sub break_all {
    my ($self, $from) = @_;
    if (blessed $from) {
        $from  = $from->id;
    }

    my $schema = Pixis::Registry->get(schema => 'master');
    $schema->txn_do( sub {
        my ($self, $from) = @_;

        my $rs = $self->resultset();
        $rs->search({
            -or => {
                from_id => $from,
                to_id   => $from
            }
        })->delete;
    }, $self, $from );
}

__PACKAGE__->meta->make_immutable;
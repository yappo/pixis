# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/API/MemberRelationship.pm 101256 2009-02-27T02:28:53.275232Z daisuke  $

package Pixis::API::MemberRelationship;
use Moose;
use namespace::clean -except => qw(meta);

__PACKAGE__->meta->make_immutable;

sub follow {
    my ($self, $from, $to) = @_;

    # Does the other person have a follow status to me? if so,
    # I say we have feelings for each other
    my $rs = Pixis::Registry->get(schema => 'master')->resultset('MemberRelationship');

    my $there_to_here = $rs->find({from_id => $to->id, to_id => $from->id});
    my $here_to_there = $rs->find_or_create(
        from_id  => $from->id,
        to_id    => $to->id,
        approved => $there_to_here ? 1 : 0
    );
    if ($there_to_here && ! $there_to_here->approved) {
        $there_to_here->approved(1);
        $there_to_here->update;
    }
}

sub unfollow {
    my ($self, $from, $to) = @_;

    # Does the other person have a follow status to me? if so,
    # I say we no longer have feelings for each other
    my $rs = Pixis::Registry->get(schema => 'master')->resultset('MemberRelationship');

    my $here_to_there = $rs->find({ from_id => $from->id, to_id => $to->id });
    if ($here_to_there) {
        $here_to_there->delete;
    }

    my $there_to_here = $rs->find({from_id => $to->id, to_id => $from->id});
    if ($there_to_here && $there_to_here->approved) {
        $there_to_here->approved(0);
        $there_to_here->update;
    }
}

sub is_mutual {
    my ($self, $from, $to) = @_;

    my $rs = Pixis::Registry->get(schema => 'master')->resultset('MemberRelationship');
    my $here_to_there = $rs->find({ from_id => $from->id, to_id => $to->id });
    my $there_to_here = $rs->find({from_id => $to->id, to_id => $from->id});
    return ($here_to_there && $there_to_here) ? 1 : ();
}

1;
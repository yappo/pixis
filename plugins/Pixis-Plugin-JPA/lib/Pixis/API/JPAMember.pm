# $Id$

package Pixis::API::JPAMember;
use Moose;
use utf8;

with 'Pixis::API::Base::DBIC';

__PACKAGE__->meta->make_immutable;

no Moose;

sub create {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get(schema => 'Master');
    my ($membership) = $schema->resultset('JPAMembership')->search({ 
        name => $args->{membership}
    })->single;
    if (! $membership) {
        confess "no such membership type: $args->{membership}";
    }
    $args->{created_on} = DateTime->now;

    $schema->txn_do(sub {
        my ($schema, $args, $membership) = @_;

        # JPA Member info
        my $member = $schema->resultset('JPAMember')->create({
            %$args,
            membership => $membership->name
        });

        # Also create a payment lot
        $schema->resultset('JPAPaymentHistory')->create({
            member_id  => $member->id,
            item_id    => $membership->id,
            amount     => $membership->price,
            created_on => $args->{created_on},
        });
    }, $schema, $args, $membership);
}

1;

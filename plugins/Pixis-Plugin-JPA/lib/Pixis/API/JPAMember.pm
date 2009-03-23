# $Id$

package Pixis::API::JPAMember;
use Moose;
use namespace::clean -except => qw(meta);

with 'Pixis::API::Base::DBIC';

__PACKAGE__->meta->make_immutable;

sub create {
    my ($self, $args) = @_;

    my $schema = Pixis::Registry->get(schema => 'Master');
    my ($item) = $schema->resultset('PurchaseItem')->search({
        id => $args->{membership}
    })->single;
    if (! $item) {
        confess "no such membership type: $args->{membership}";
    }

    return $schema->txn_do(sub {
        my ($schema, $args, $item) = @_;

        # JPA Member info (don't confuse it with pixis member!)
        my $member = $schema->resultset('JPAMember')->create({
            %$args,
            is_active  => 0, # must be
            created_on => \'NOW()',
            membership => $item->id
        });

        # Also create an order for this signup
        my $order;
        if ($item->price <= 0) {
#            if (DEBUG) {
                print STDERR "new member does not require a fee\n";
#            }

            # Students need not pay, but they need to give us a 
            # proof (a copy of their school ID)
        } else {
            my $order_api = Pixis::Registry->get(api => 'Order');
            $order = $order_api->create( {
                member_id   => $args->{member_id}, # pixis member ID
                amount      => $item->price,
                description => $item->description,
                created_on  => \'NOW()',
            });
        }
        return ($member, $order);
    }, $schema, $args, $item);
}

1;

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

        my $now = DateTime->now;
        # JPA Member info (don't confuse it with pixis member!)
        my $member = $schema->resultset('JPAMember')->create({
            %$args,
            is_active  => 0, # must be
            created_on => $now,
            membership => $item->name
        });

        # Also create an order for this signup
        if ($item->price <= 0) {
#            if (DEBUG) {
                print STDERR "new member does not require a fee\n";
#            }

            # Students need not pay, but they need to give us a 
            # proof (a copy of their school ID)
        } else {
            my $order_api = Pixis::Registry->get(api => 'Order');
            return $order_api->create( {
                member_id   => $args->{member_id}, # pixis member ID
                amount      => $item->price,
                description => $item->description,
                created_on  => $now,
            });
        }
    }, $schema, $args, $item);
}

1;

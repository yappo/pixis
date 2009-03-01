
package Pixis::API::JPAPaymentHistory;
use Moose;
use namespace::clean -except => qw(meta);

with 'Pixis::API::Base::DBIC';

__PACKAGE__->meta->make_immutable;

1;

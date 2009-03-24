package Pixis::API::EventRegistration;
use Moose;
use namespace::clean -except => qw(meta);

with 'Pixis::API::Base::DBIC';

sub load_from_order {
    my ($self, $args) = @_;

    return $self->resultset->search(
        {
            member_id => $args->{member_id},
            order_id => $args->{order_id},
        }
    )->single;
}

sub activate {
    my ($self, $args) = @_;

    return $self->resultset
        ->search(
            {
                id => $args->{id},
            }
        )
        ->update(
            {
                is_active => 1,
            },
        )
    ;
        
}

__PACKAGE__->meta->make_immutable;


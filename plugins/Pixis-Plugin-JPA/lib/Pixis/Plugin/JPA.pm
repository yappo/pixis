
package Pixis::Plugin::JPA;
use Moose;
use namespace::clean -except => qw(meta);

with 'Pixis::Plugin';

has '+navigation' => (
    default => sub {
        [
            {
                text => "JPA",
                url  => "/jpa"
            },
            {
                text => "JPA Wiki",
                url  => "http://wiki.perlassociation.org"
            },
            {
                text => "JPA Services",
                url => "/jpa/service"
            }
        ]
    }
);

has '+extra_api' => (
    default => sub { +[ qw(JPAMember) ] }
);

__PACKAGE__->meta->make_immutable;

1;
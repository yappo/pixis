
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

after 'register' => sub {
    my $registry = Pixis::Registry->instance;
    my $c = $registry->get(pixis => 'web');

    push @{$c->controller('Signup')->steps}, '/jpa/signup/contd' ;
};

__PACKAGE__->meta->make_immutable;

1;
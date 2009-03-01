# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/Registry.pm 99505 2009-02-03T03:28:19.287739Z daisuke  $

package Pixis::Registry;
use MooseX::Singleton;
use MooseX::AttributeHelpers;
use namespace::clean -except => qw(meta);

use constant DEBUG => $ENV{PIXIS_DEBUG};

has '__registry' => (
    metaclass => 'Collection::Hash',
    is        => 'rw', 
    isa       => 'HashRef',
    default   => sub { +{} },
    provides  => {
        get => 'get',
        set => 'set',
    }
);

around 'get' => sub {
    my ($next, $self, @args) = @_;
    if (! blessed $self) {
        $self = $self->instance;
    }
    my $key = $self->__to_key(@args);
    if (DEBUG) {
        print STDERR "[REGISTRY] GET $key\n";
    }
    $next->($self, $key);
};

around 'set' => sub {
    my ($next, $self, @args) = @_;
    if (! blessed $self) {
        $self = $self->instance;
    }
    my $value = pop @args;
    my $key = $self->__to_key(@args);
    if (DEBUG) {
        print STDERR "[REGISTRY] SET $key => $value\n";
    }
    $next->($self, $key, $value);
};

no MooseX::Singleton;

sub __to_key {
    my $self = shift;
    return join('.', map { my $x = $_; $x =~ s/\./\_/g; lc $x } @_ );
}

1;
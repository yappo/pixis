# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/Web/Model/API.pm 101259 2009-02-27T04:36:03.762330Z daisuke  $

package Pixis::Web::Model::API;
use strict;
use base qw(Catalyst::Model);
use Pixis::Registry;
use Pixis::Schema::Master;

sub COMPONENT {
    my ($self, $c, @args) = @_;

    my $registry = Pixis::Registry->instance;

    # setup the schemas first
    $registry->set( schema => 'master',
        Pixis::Schema::Master->connection(@{$c->config->{'Schema::Master'}->{connect_info}}));

    my $config = $c->config->{'Model::API'};

    my $apis = $config->{apis} || [];
    unshift @$apis, map { +{ class => $_ } } qw(Member MemberAuth MemberRelationship Payment::Paypal);
    foreach my $config (@$apis) {
        $config = { %$config };
        my $class = delete $config->{class} || die "'class' is required";
        if ($class !~ s/^\+//) {
            $class = "Pixis::API::$class";
        }
        $c->log->debug("Loading API '$class'") if $c->log->is_debug;
        my @key   = split(/::/, lc $class);
        # pop Pixis::API 
        shift @key;
        Class::MOP::load_class($class);
        $registry->set( @key, $class->new() );
    }

    return $registry
}

1;
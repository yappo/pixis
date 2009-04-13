# $Id$

package Pixis::Plugin::Core;
use Moose;
use namespace::clean -except => qw(meta);
with 'Pixis::Plugin';

before register => sub {
    my ($self, $c) = @_;

    my $config = $c->config();

    my $registry = Pixis::Registry->instance;
    foreach my $name qw(Master) {
        my $schema_config = $config->{"Schema::$name"};
        my $module = "Pixis::Schema::$name";
        Class::MOP::load_class($module);
        my $schema = $module->connection( @{$schema_config->{connect_info}} );
        $registry->set("schema" => $name => $schema);
    }

    my @list;
    foreach my $name qw(Member MemberAuth MemberRelationship Order Payment::Paypal Payment::Transaction) {
        my $api_config = $config->{"API::$name"} || {};
        my $module     = "Pixis::API::$name";
        Class::MOP::load_class($module);
        my $api = $module->new(%$api_config);
        push @list, $api;
    }
    $self->extra_api(\@list);
};

__PACKAGE__->meta->make_immutable();
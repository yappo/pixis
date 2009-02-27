# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/Plugin.pm 99505 2009-02-03T03:28:19.287739Z daisuke  $

package Pixis::Plugin;
use Moose::Role;

requires 'register';

has 'registered' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

no Moose::Role;

1;

__END__

=head1 NAME

Pixis::Plugin - Pixis Plugin

=head1 SYNOPSIS

    my $plugin = Pixis::Plugin::MyPlugin->new(...);
    $plugin->register;

=cut
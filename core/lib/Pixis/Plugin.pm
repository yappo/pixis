# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/Plugin.pm 99505 2009-02-03T03:28:19.287739Z daisuke  $

package Pixis::Plugin;
use namespace::clean -except => [ qw(meta) ];
use Moose::Role;
use Moose::Util::TypeConstraints;
use MooseX::AttributeHelpers;

requires 'register';

has 'registered' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

subtype 'Pixis::Plugin::Types::IncludePathList'
    => as 'ArrayRef'
;

coerce 'Pixis::Plugin::Types::IncludePathList'
    => from 'Str'
    => via { [ Path::Class::File->new($_) ] }
;

coerce 'Pixis::Plugin::Types::IncludePathList'
    => from 'ArrayRef[Str]'
    => via { [ map { Path::Class::File->new($_) } @$_] }
;

has 'include_path' => (
    metaclass => 'Collection::List',
    is => 'rw', 
    isa => 'Pixis::Plugin::Types::IncludePathList',
    coerce => 1,
    lazy_build => 1,
    auto_deref => 1,
    provides => {
        count => 'include_path_count'
    }
);

no namespace::clean;

sub _build_include_path {
    my $self = shift;
    my $class = blessed($self);
    $class =~ s{::}{/}g;
    $class =~ s/$/\.pm/;
    my $path  = Path::Class::File->new($INC{$class});
    [ $path->parent->parent->parent->parent->subdir('root')->absolute ];
}

1;

__END__

=head1 NAME

Pixis::Plugin - Pixis Plugin

=head1 SYNOPSIS

    my $plugin = Pixis::Plugin::MyPlugin->new(...);
    $plugin->register;

=cut
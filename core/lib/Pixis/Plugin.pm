package Pixis::Plugin;
use Moose::Role;
use Moose::Util::TypeConstraints;
use YAML ();
use Path::Class::File;
use namespace::clean -except => [ qw(meta) ];

has 'registered' => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);

subtype 'Pixis::Plugin::Types::PathList'
    => as 'ArrayRef'
;

coerce 'Pixis::Plugin::Types::PathList'
    => from 'Str'
    => via { [ Path::Class::File->new($_) ] }
;

coerce 'Pixis::Plugin::Types::PathList'
    => from 'ArrayRef[Str]'
    => via { [ map { Path::Class::File->new($_) } @$_] }
;

has 'include_path' => (
    is => 'rw', 
    isa => 'Pixis::Plugin::Types::PathList',
    coerce => 1,
    lazy_build => 1,
    auto_deref => 1,
);

has 'static_path' => (
    is => 'rw', 
    isa => 'Pixis::Plugin::Types::PathList',
    coerce => 1,
    lazy_build => 1,
    auto_deref => 1,
);

has 'formfu_path' => (
    is => 'rw', 
    isa => 'Pixis::Plugin::Types::PathList',
    coerce => 1,
    lazy_build => 1,
    auto_deref => 1,
);

has 'translation_path' => (
    is => 'rw', 
    isa => 'ArrayRef',
    lazy_build => 1,
    auto_deref => 1,
);

has 'tt_preprocess' => (
    is => 'rw',
    isa => 'Maybe[Str]',
    lazy_build => 1,
);

subtype 'Pixis::Plugin::Types::APIList'
    => as 'ArrayRef'
;

coerce 'Pixis::Plugin::Types::APIList'
    => from 'ArrayRef[Str]',
    => via {
        [ map {
            my $class = "Pixis::API::$_";
            Class::MOP::load_class($class);
            $class->new()
        } @$_ ]
    }
;

has 'extra_api' => (
    is => 'rw',
    isa => 'Pixis::Plugin::Types::APIList',
    auto_deref => 1,
    coerce => 1,
);

sub _build_tt_preprocess {
    my $self = shift;
    my $name = blessed $self;
    $name =~ s/Pixis::(?:Web::)?Plugin:://;
    $name =~ s/::/_/;
    $name = lc($name) . '.tt';
    foreach my $path ($self->include_path) {
        my $file = Path::Class::File->new($path, $name);
        if (-f $file) {
            return $name;
        }
    }
    return ();
}

sub _build_include_path {
    my $self = shift;
    my $class = blessed($self);
    $class =~ s{::}{/}g;
    $class =~ s/$/\.pm/;
    my $path  = Path::Class::File->new($INC{$class});
    return [ $path->parent->parent->parent->parent->subdir('root')->absolute ];
}

sub _build_static_path {
    my $self = shift;
    return $self->include_path;
}

sub _build_formfu_path {
    my $self = shift;
    return [ map { Path::Class::Dir->new($_, 'forms') } $self->include_path ];
}

sub _build_translation_path {
    my $self = shift;
    my $class = blessed($self);
    $class =~ s{::}{/}g;
    my $file = "$class.pm";
    my $path = $INC{ $file };
    $path =~ s{\.pm$}{/I18N/*.po};
    [ $path ];
}

sub register {
    my $self = shift;

    my $registry = Pixis::Registry->instance;
    my $c = $registry->get(pixis => 'web');

    $c->add_tt_include_path($self->include_path);
    $c->add_static_include_path($self->static_path);
    $c->add_formfu_path($self->formfu_path);
    $c->add_translation_path($self->translation_path);
#    if ($self->has_navigation) {
#        $c->add_navigation($_) for @{$self->navigation};
#    }
    $registry->set(api => (split(/::/, blessed($_)))[-1], $_)
        for $self->extra_api;
}

1;

__END__

=head1 NAME

Pixis::Plugin - Pixis Plugin

=head1 SYNOPSIS

    my $plugin = Pixis::Plugin::MyPlugin->new(...);
    $plugin->register;

=cut
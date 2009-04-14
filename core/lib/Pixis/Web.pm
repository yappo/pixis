package Pixis::Web;

use strict;
use warnings;

use Template::Provider::Encoding;
use Template::Stash::ForceUTF8;

use Pixis::Hacks;
use Pixis::Registry;
use Catalyst::Runtime '5.70';
use parent qw(Catalyst);
use Catalyst qw(
    Authentication
    Authorization::Roles
    ConfigLoader
    Data::Localize
    Session
    Session::Store::File
    Session::State::Cookie
    Static::Simple
    Unicode
);
use Module::Pluggable::Object;
use Pixis::Web::Exception;

our $VERSION = '0.01';

__PACKAGE__->config(
    name => 'Pixis::Web',
    default_view => 'TT',
    static => {
        dirs => [ 'static' ]
    },
    'Controller::HTML::FormFu' => {
        languages_from_context  => 1,
        localize_from_context  => 1,
        constructor => {
            render_method => 'tt',
            tt_args => {
                COMPILE_DIR  => __PACKAGE__->path_to('tt2'),
                INCLUDE_PATH => __PACKAGE__->path_to('root', 'forms')->stringify,
            }
        }
    },
    'Plugin::Authentication' => {
        use_session => 1,
        default_realm => 'members',
        realms => {
            members => {
                credential => {
                    class => 'Password',
                    password_field => 'password',
                    password_type  => 'hashed',
                    password_hash_type => 'SHA-1',
                },
                store => {
                    class => 'DBIx::Class',
                    id_field => 'email',
                    role_column => 'roles',
                    user_class => 'DBIC::Member',
                }
            },
            members_internal => {
                credential => {
                    class => 'Password',
                    password_field => 'password',
                    password_type  => 'clear',
                },
                store => {
                    class => 'DBIx::Class',
                    id_field => 'email',
                    role_column => 'roles',
                    user_class => 'DBIC::Member',
                }
            }
        }
    },
    'View::JSON' => {
        expose_stash => 'json'
    },
    'View::TT' => {
        PRE_PROCESS => 'preprocess.tt',
        LOAD_TEMPLATES => [
            Template::Provider::Encoding->new(
                INCLUDE_PATH => [ __PACKAGE__->path_to('root') ],
                COMPILE_DIR  => __PACKAGE__->path_to('tt2'),
            )
        ],
        STASH   => Template::Stash::ForceUTF8->new,
    }
);

# mk_classdata is overkill for these.
my %REGISTERED_PLUGINS = ();
my %TT_ARGS            = ();
my @PLUGINS            = ();

our $REGISTRY = Pixis::Registry->instance;
sub registry {
    shift;
    # XXX the initialization code is currently at Model::API. Should this
    # be changed?
    $REGISTRY->get(@_);
}

sub setup {
    my $self = shift;

    $REGISTRY->set(pixis => web => $self);

    # for various reasons, we /NEED/ to have Catalyst setup itself before
    # we setup our plugins.
    push @_, $ENV{CATALYST_DEBUG} ? "-log=error,debug" : "-log=error";
    $self->SUPER::setup(@_);
}

sub setup_pixis_plugins {
    my $self = shift;

    # set the search path so we can look for plugins
    my $search_path = $self->config->{plugins}->{search_path} || [];
    # make sure the paths contain valid-ish (defined) items
    $search_path = [ grep { defined $_ && length $_ > 0 } @$search_path ];
    unshift @INC, @$search_path if scalar @$search_path;

    # Core must be read-in before everything else
    # (it will be discovered by Module::Pluggable, and we wouldn't
    # load it twice anyway, so we're safe to just stick it in the front)
    my $mpo = Module::Pluggable::Object->new(
        require => 1,
        search_path => [
            'Pixis::Plugin',
            'Pixis::Web::Plugin'
        ]
    );

    my @plugins = $mpo->plugins;

    foreach my $plugin (@plugins) {
        my $pkg = $plugin;
        my $args = $self->config->{plugins}->{config}->{$plugin} || {} ;
        $plugin = $pkg->new(%$args);
        if (! $plugin->registered && !($REGISTERED_PLUGINS{ $pkg }++) ){
            print STDERR "[Pixis Plugin]: Registring $pkg\n";
            $plugin->register($self);
            $plugin->registered(1);
            push @PLUGINS, $plugin;
        }
    }
}

sub plugins { \@PLUGINS }

# Note: This exists *solely* for the benefit of pixis_web_server.pl
# In your real app (fastcgi deployment suggested), you need to do something
# like:
#   Alias /static/<plugin>  /path/to/plugin/root/static/<plugin>
sub add_static_include_path {
    my ($self, @paths) = @_;

    my $config = $self->config->{static};
    $config->{include_path} ||= [];
    push @{$config->{include_path}}, @paths;
}

sub add_tt_include_path {
    my ($self, @paths) = @_;

    @paths = grep { defined && length } @paths;
    return unless @paths;

    my $view = $self->view('TT');
    my $providers = $view->{LOAD_TEMPLATES};
    if ($providers) {
        foreach my $provider (@$providers) {
            $provider->include_path([
                @paths,
                @{ $provider->include_path || [] }
            ]);
        }
    }
    $view->include_path(
        @paths,
        @{ $view->include_path }
    );
}

sub add_translation_path {
    my ($self, @paths) = @_;

    # we're using gettext by default, just look for a localize by that
    # type in the localizer
    my $localize = $self->model('Data::Localize');
    my ($localizer) = $localize->find_localizers(isa => 'Data::Localize::Gettext');

    $localizer->path_add( $_ ) for @paths;
}

sub add_formfu_path {
    my ($self, @paths) = @_;

    foreach my $controller (map { $self->controller($_) } $self->controllers) {
        my $code = $controller->can('_html_formfu_config');
        next unless $code;

        my $orig   = $code->($controller)->{constructor}{config_file_path};
        if (defined $orig && ref($orig) ne 'ARRAY') {
            $orig = [$orig];
            $code->($controller)->{constructor}{config_file_path} = $orig;
        }
        my %seen = map { ($_ => 1) } @$orig;
        foreach my $path (@paths) {
            next if $seen{$path};
            push @$orig, $path;
        }
    }
}

__PACKAGE__->setup();
__PACKAGE__->setup_pixis_plugins();

sub finalize {
    my ( $c ) = shift;
    $c->handle_exception if @{ $c->error };
    $c->NEXT::finalize( @_ );
}

sub handle_exception {
    my( $c )  = @_;
    my $error = $c->error->[ 0 ];

    if( !Scalar::Util::blessed( $error ) or !$error->isa( 'Pixis::Web::Exception' ) ) {
        $error = Pixis::Web::Exception->new( message => "$error" );
    }

    # handle debug-mode forced-debug from RenderView
    if( $c->debug && $error->message =~ m{^forced debug} ) {
        return;
    }

    $c->clear_errors;

    if ( $error->is_error ) {
        $c->response->headers->remove_content_headers;
    }

    if ( $error->has_headers ) {
        $c->response->headers->merge( $error->headers );
    }

    # log the error
    if ( $error->is_server_error ) {
        $c->log->error( $error->as_string );
    }
    elsif ( $error->is_client_error ) {
        $c->log->warn( $error->as_string ) if $error->status =~ /^40[034]$/;
    }

    if( $error->is_redirect ) {
        # recent Catalyst will give us a default body for redirects

        if( $error->can( 'uri' ) ) {
            $c->response->redirect( $error->uri( $c ) );
        }

        return;
    }

    $c->response->status( $error->status );
    $c->response->content_type( 'text/html; charset=utf-8' );
    $c->response->body(
        $c->view( 'TT' )->render( $c, 'error.tt', { error => $error } )
    );

    # processing the error has bombed. just send it back plainly.
    $c->response->body( $error->as_public_html ) if $@;
}

$SIG{ __DIE__ } = sub {
    return if Scalar::Util::blessed( $_[ 0 ] );
    die $_[0] if $_[0] eq 'catalyst_detach';
    if ($_[0] ne 'No such file or directory') {
        Pixis::Web::Exception->throw( message => join '', @_ );
    }
};

1;

__END__

=head1 WRITING PLUGINS

To write a plugin, create an object that implements 'register'. Use the following methods to add the appropriate 'stuff' for your plugin:

=over 4

=item add_tt_include_path

Adds include paths for your templates

=item add_navigation

Add a hash that gets translated into the (global) navigation bar

=item add_translation

Add localization data

=back

=cut




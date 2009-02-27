# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/Hacks.pm 101266 2009-02-27T05:47:36.185312Z daisuke  $

package Pixis::Hacks;
use strict;
use HTML::FormFu;
use Catalyst::Controller::HTML::FormFu;

BEGIN {
    # XXX - voodoo to make config values not choke on multibyte chars
    eval "require YAML::Syck";
    if (!$@) {
        $YAML::Syck::ImplicitUnicode = 1;
    }
}


# HTML::FormFu doesn't quite work with newer Locale::Maketext.
# until stuch new version is available, we override the problematic
# portions from HTML::FormFu
# http://rt.cpan.org/Public/Bug/Display.html?id=42928
if ($HTML::FormFu::VERSION <= 0.03007) {
    no warnings 'redefine';

    package HTML::FormFu::Localize;
    my $sub = sub {
        my ( $self, @original_strings ) = @_;

        @original_strings = grep { defined } @original_strings;

        if ( !$self->{has_default_localize_object} ) {
            $self->add_default_localize_object;
        }

        my @localized_strings;

        foreach my $localize_data ( @{ $self->{localize_data} } ) {
            my $localize_object = $self->get_localize_object($localize_data);
    
            eval {
                @localized_strings = $localize_object->localize(@original_strings);
            };

            next if $@;

            # NOTE:
            # As FormFu uses L10N to return messages based on artificial message
            # ids (instead of english language as message ids) the assumption
            # that we just got a result from Locale::Maketext with AUTO = 1 seems
            # to be safe when localize returns the same string as handed over.
            if (   !$localize_data->{dies_on_missing_key}
                && scalar(@original_strings) == scalar(@localized_strings)
                && scalar( List::MoreUtils::any { !$_ } List::MoreUtils::pairwise { $a eq $b } @original_strings,
                    @localized_strings ) == 0
                )
            {
                next;
            }

            last if @localized_strings;
        }

        if ( !@localized_strings ) {
            @localized_strings = @original_strings;
        }

        return wantarray ? @localized_strings : $localized_strings[0];
    };

    *HTML::FormFu::Localize::localize = $sub;
    *HTML::FormFu::localize = $sub;
    *HTML::FormFu::loc = $sub;
}

# HTML::FormFu can't handle multiple search paths for the forms.
# http://rt.cpan.org/Public/Bug/Display.html?id=43529
{
    no warnings 'redefine';
    package HTML::FormFu::ObjectUtil;
    sub _load_config {
        my ( $self, $use_stems, @filenames ) = @_;

        if( scalar @filenames == 1 && ref $filenames[0] eq 'ARRAY' ) {
            @filenames = @{$filenames[0]};
        }

        # ImplicitUnicode ensures that values won't be double-encoded when we
        # encode() our output
        local $YAML::Syck::ImplicitUnicode = 1;

        my $config_callback = $self->config_callback;
        my $data_visitor;

        if ( defined $config_callback ) {
            $data_visitor = Data::Visitor::Callback->new( %$config_callback,
            ignore_return_values => 1, );
        }

        my $config_any_arg    = $use_stems ? 'stems'      : 'files';
        my $config_any_method = $use_stems ? 'load_stems' : 'load_files';

        my @config_file_path;
        if (my $config_file_path = $self->config_file_path) {
            if (ref $config_file_path eq 'ARRAY') {
                push @config_file_path, @$config_file_path;
            } else {
                push @config_file_path, $config_file_path;
            }
        }
        push @config_file_path, File::Spec->curdir;

        for my $file (@filenames) {
            my $loaded = 0;
            my $fullpath;
            foreach my $config_file_path (@config_file_path) {
                if ( defined $config_file_path
                     && !File::Spec->file_name_is_absolute($file)
                    )
                {
                    $fullpath = File::Spec->catfile( $config_file_path, $file );
                } else {
                    $fullpath = $file;
                }

                my $config = Config::Any->$config_any_method( {
                    $config_any_arg => [$fullpath],
                    use_ext         => 1,
                    driver_args     => {
                        General => { -UTF8 => 1 },
                    },
                } );

                next if ! @$config;

                $loaded = 1;
                my ( $filename, $filedata ) = %{ $config->[0] };

                _load_file( $self, $data_visitor, $filedata );
            }
            Carp::croak "config file '$file' not found" if !$loaded;
        }

        return $self;
    };
}


1;
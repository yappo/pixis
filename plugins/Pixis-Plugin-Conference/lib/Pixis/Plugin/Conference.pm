# $Id: /mirror/pixis/Pixis-Plugin-Conference/trunk/lib/Pixis/Plugin/Conference.pm 101271 2009-02-27T05:53:14.753641Z daisuke  $

package Pixis::Plugin::Conference;
use Moose;
use MooseX::AttributeHelpers;
use DateTime;
use Pixis::API::ConferenceSession;
use Pixis::API::ConferenceTrack;

with 'Pixis::Plugin';


has 'include_path' => (
    metaclass => 'Collection::List',
    is => 'rw', 
    isa => 'ArrayRef',
    default => sub {
        my $class = __PACKAGE__;
        $class =~ s{::}{/}g;
        $class =~ s/$/\.pm/;
        my $path  = Path::Class::File->new($INC{$class});
        [ $path->parent->parent->parent->parent->subdir('root')->absolute ];
    },
    auto_deref => 1,
    provides => {
        count => 'include_path_count'
    }
);

__PACKAGE__->meta->make_immutable;

no Moose;

sub BUILDARGS {
    my $class = shift;
    my $args  = @_ > 1 ? { @_ } : $_[0];

    if ($args->{include_path} && ref $args->{include_path} ne 'ARRAY') {
        $args->{include_path} = [ $args->{include_path} ];
    }
    return $args;
}

sub register {
    my $self = shift;

    my $c = Pixis::Registry->get(pixis => 'web');
    $c->add_tt_include_path($self->include_path);
    $c->add_formfu_path(map { Path::Class::Dir->new($_, 'forms') } $self->include_path);

    $c->add_navigation(
        { 
            text => "Conference",
            url => "/conference"
        }
    );

    my $path = do {
        my $class = __PACKAGE__;
        $class =~ s{::}{/}g;
        my $file = "$class.pm";
        my $path = $INC{ $file };
        $path =~ s{\.pm$}{/I18N/*.po};
        $path;
    };
    $c->add_translation( $path );

    Pixis::Registry->set(api => 'ConferenceTrack',
        Pixis::API::ConferenceTrack->new());
    Pixis::Registry->set(api => 'ConferenceSession',
        Pixis::API::ConferenceSession->new());
}

1;
# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/Web/Plugin/Core.pm 101263 2009-02-27T05:09:36.886763Z daisuke  $

package Pixis::Web::Plugin::Core;
use Moose;

with 'Pixis::Plugin';

__PACKAGE__->meta->make_immutable;

no Moose;

sub register {
    my $self = shift;
    my $c    = Pixis::Registry->get(pixis => 'web');
    if ($c) {
        $c->add_navigation(
            {
                text => "Home",
                url => "/member/home"
            },
        );
    }
}

1;
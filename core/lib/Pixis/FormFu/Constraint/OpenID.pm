# $Id$

package Pixis::FormFu::Constraint::OpenID;
use strict;
use base 'HTML::FormFu::Constraint';
use Pixis::Registry;
use Pixis::API::MemberAuth;

sub constrain_value {
    my ($self, $value) = @_;

    my $api = Pixis::Registry->get(api => 'MemberAuth');
    my $x = $api->load_auth(
        {
            auth_type => 'openid',
            auth_data => $value
        }
    );

    return defined $x;
}

1;
# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/Web/Model/DBIC/Member.pm 99505 2009-02-03T03:28:19.287739Z daisuke  $

package Pixis::Web::Model::DBIC::Member;
use strict;
use Pixis::Registry;
use Pixis::Schema::Master::Member;

sub ACCEPT_CONTEXT {
    return Pixis::Registry->get(schema => 'master')->resultset('Member');
}

1;
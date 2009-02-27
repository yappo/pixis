use strict;
use utf8;
use Test::More (tests => 1);
use Apache::Test qw(:withtestmore);
use Apache::TestRequest qw(GET);
use Apache::TestUtil;
use URI;
# use Test::WWW::Mechanize;

# Get the test server's address. 
my $BASE_URL = URI->new();
$BASE_URL->scheme('http');
$BASE_URL->host_port($ENV{PIXIS_HOSTPORT} || Apache::TestRequest::hostport());

{
#    local $Apache::TestRequest::DebugLWP = 1;
    my $res = GET $BASE_URL, 'Accept-Language' => 'ja';
    my $content = $res->decoded_content;

#    t_debug($content);
    ok( index($content, 'ホーム') > -1, "'ホーム' found");
 
}

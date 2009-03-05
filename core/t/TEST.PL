use lib "t/lib";
use Test::Pixis::TestRun;
use Path::Class::Dir;
use Path::Class::File;

$ENV{MYAPP_HOME}    ||= Path::Class::Dir->new()->absolute->stringify;
$ENV{MYAPP_PIDFILE} ||= Path::Class::File->new('t', 'fastcgi.pid')->absolute->stringify;
$ENV{MYAPP_SOCKET}  ||= Path::Class::File->new('t', 'fastcgi.sock')->absolute->stringify;

Test::Pixis::TestRun->new->run(@ARGV);
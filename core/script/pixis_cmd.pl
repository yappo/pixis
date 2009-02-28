#!/usr/local/bin/perl
use strict;
use Path::Class::File;

my @libs;

# XXX This script is a HACK! - beware!
my $BASEDIR;
{
    my $file = Path::Class::File->new(__FILE__)->absolute;

    # first, add our own lib
    push @libs, $file->parent->parent->subdir('lib');

    my $cur = $file;

    do {
        if ($cur =~ /core$/) {
            $BASEDIR = $cur->parent;
            last;
        }
    } while ($cur = $cur->parent);
}

while (glob("$BASEDIR/plugins/Pixis-Plugin-*/lib")) {
    next unless -d $_;
    push @libs, $_;
}


$ENV{PERL5LIB} = join(':', @libs, $ENV{PERL5LIB}) ;
# if this command was _server.pl, then include the plugin directories
# in the restart directory list
if ($ARGV[0] =~ /_server.pl$/) {
    push @ARGV, map { s/\blib$//; "--restartdirectory=$_" } @libs;
}


exec(@ARGV);

__END__

=head1 NAME

pixis_cmd.pl - Run Pixis CLI Stuff, Taking Note Of Plugins (for development)

=head1 SYNOPSIS

    pixis_cmd.pl <cmd>

=head1 CAVEATS

I expect you to have this file in a directory called core, and plugins reside
in a directory named plugins/Plugin-Name/

=cut

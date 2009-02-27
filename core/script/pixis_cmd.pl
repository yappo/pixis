#!/usr/local/bin/perl
use strict;
use Path::Class::File;

# XXX This is a HACK!
my $BASEDIR;
{
    my $file = Path::Class::File->new(__FILE__)->absolute;
    my $cur = $file;

    do {
        if ($cur =~ /Pixis-Core$/) {
            $BASEDIR = $cur->parent;
            last;
        }
    } while ($cur = $cur->parent);
}

my @libs;
while (glob("$BASEDIR/Pixis-*/trunk/lib")) {
    next unless -d $_;
    push @libs, $_;
}


$ENV{PERL5LIB} = join(':', @libs, $ENV{PERL5LIB}) ;

exec(@ARGV);

__END__

=head1 NAME

pixis_cmd.pl - Run Pixis CLI Stuff, Taking Note Of Plugins

=head1 SYNOPSIS

    pixis_cmd.pl <cmd>

=head1 CAVEATS

I expect you to have this file in a directory called Pixis-Core
(with or without trunk/branch)

=cut

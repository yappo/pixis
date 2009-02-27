# WARNING: this file is generated, do not edit
# generated on Wed Feb  4 14:45:57 2009
# 01: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestConfig.pm:955
# 02: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestConfig.pm:973
# 03: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestConfigPerl.pm:238
# 04: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestConfig.pm:626
# 05: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestConfig.pm:641
# 06: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestConfig.pm:1623
# 07: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestRun.pm:507
# 08: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestRunPerl.pm:90
# 09: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestRun.pm:725
# 10: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestRun.pm:725
# 11: /Users/daisuke/svk/pixis/Pixis-Core/trunk/t/TEST:11

BEGIN {
    use lib '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t';
    for my $file (qw(modperl_inc.pl modperl_extra.pl)) {
        eval { require "conf/$file" } or
            die if grep { -e "$_/conf/$file" } @INC;
    }

    if (($ENV{HARNESS_PERL_SWITCHES}||'') =~ m/Devel::Cover/) {
        eval {
            # 0.48 is the first version of Devel::Cover that can
            # really generate mod_perl coverage statistics
            require Devel::Cover;
            Devel::Cover->VERSION(0.48);

            # this ignores coverage data for some generated files
            Devel::Cover->import('+inc' => 't/response/',);

            1;
        } or die "Devel::Cover error: $@";
    }

}

1;

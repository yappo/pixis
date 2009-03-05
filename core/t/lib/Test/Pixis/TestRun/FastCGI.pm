package Test::Pixis::TestRun::FastCGI;
use Moose;
use Path::Class::Dir;
use Path::Class::File;
use POSIX 'setsid';

sub register {
    my ($self, $runner) = @_;

    my $meta = $runner->meta;
    $meta->add_before_method_modifier('start', sub {
        if (! $ENV{NO_FASTCGI}) {
            $self->start_fastcgi(@_);
            print "started fastcgi\n";
        }
    });
    $meta->add_after_method_modifier('stop', sub {
        if (! $ENV{NO_FASTCGI}) {
            $self->stop_fastcgi(@_);
            print "stopped fastcgi\n";
        }
    });
    $meta->add_after_method_modifier('install_sighandlers', sub {
        $self->install_sighandlers();
    });
}

sub start_fastcgi {
    my $self = shift;

    print "starting fastcgi\n";
    my $home    = $ENV{MYAPP_HOME};
    my $pidfile = $ENV{MYAPP_PIDFILE};
    my $listen  = $ENV{MYAPP_SOCKET};

    { # make sure that no previous instances are running
        if (-f $pidfile) {
            open (my $fh, '<', $pidfile) or
                die "Could not open file $pidfile for reading: $!";

            my $pid = <$fh>;
            close $fh;

            chomp $pid;    
            if ($pid && kill 0 => $pid) {
                print STDERR "PID $pid is still alive\n";
                CORE::exit(1);
            }
            CORE::unlink $pidfile;
        }
    }


    { # fork/exec to start fastcgi script
        local $SIG{CHLD} = sub {
            print STDERR "Child prematurely exited\n";
            CORE::exit(1);
        };

        my $pid = fork();
        if (! defined $pid) {
            print STDERR "Could not fork: $!\n";
            CORE::exit(1);
        }

        if ($pid) { # parent
            # wait until the pid file we've requested 
            my $timeout = time + 60;
            my $ok = 0;
            while (! -f $pidfile && $timeout > time() ) {
                sleep 1;
            }

            if (! -f $pidfile) {
                print STDERR "FastCGI script did not start. Please check your script\n";
                CORE::exit(1);
            }
        } else {
            $ENV{MYAPP_HOME}    = $home;
            $ENV{MYAPP_PIDFILE} = $pidfile;
            $ENV{MYAPP_SOCKET}  = $listen;
            setsid() or die "Could not setsid";
            my $cmd = Path::Class::File->new($home, 'script', 'run.sh')->absolute->stringify;
            exec($cmd) or die "Failed to run script: $!";
            exit 1;
        }
    }
}

sub install_sighandlers {
    my $self = shift;
    my $old = $SIG{__DIE__}; # capture this sucker
    $SIG{__DIE__} = sub {
        return unless $_[0] =~ /^Failed/i; #dont catch Test::ok failures

        $self->stop_fastcgi;
        $old->(@_);
    };
}

sub stop_fastcgi {
    my $self = shift;

    my $home    = $ENV{MYAPP_HOME};
    my $pidfile = $ENV{MYAPP_PIDFILE};
    my $listen  = $ENV{MYAPP_SOCKET};

    if (-f $pidfile) {
        open (my $fh, '<', $pidfile) or
            die "Could not open file $pidfile for reading: $!";

        my $pid = <$fh>;
        close $fh;

        chomp $pid;

        if ($pid) {
            # wait until the pid file we've killed it
            my $timeout = time + 60;
            while ( kill TERM => $pid && $timeout > time() ) {
                sleep 1;
            }

            if (kill TERM => $pid)  {
                print STDERR "PID $pid is still alive\n";
            }
            CORE::unlink $pidfile;
        }
    }
}

1;


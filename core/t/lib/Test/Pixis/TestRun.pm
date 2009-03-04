
package Test::Pixis::TestRun;
use Moose;
use Module::Pluggable::Object;
use namespace::clean -except => qw(meta);

extends 'Apache::TestRun';

after 'new' => sub {
    my $self = shift;
    my $plugins = Module::Pluggable::Object->new(
        search_path => "Test::Pixis",
        search_dirs => "t/lib",
        except      => [ "Test::Pixis::TestRun" ],
        instantiate => 'new',
    );

    foreach my $plugin ($plugins->plugins) {
        $plugin->register($self);
    }
    $self;
};

1;

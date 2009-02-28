# $Id: /mirror/pixis/Pixis-Core/trunk/lib/Pixis/CLI/SetupDB.pm 101264 2009-02-27T05:10:06.352581Z daisuke  $

package Pixis::CLI::SetupDB;
use Moose;
use DateTime;
use Digest::SHA1 qw(sha1_hex);
use Pixis::Schema::Master;

with 'MooseX::Getopt';

has 'dsn' => (
    is => 'rw',
    isa => 'Str',
    required => 1,
);

has 'username' => (
    is => 'rw',
    isa => 'Str',
);

has 'password' => (
    is => 'rw',
    isa => 'Str',
);

has 'drop' => (
    is => 'rw',
    isa => 'Bool',
    default => 0
);

__PACKAGE__->meta->make_immutable;

no Moose;

sub run {
    my $self = shift;
    my $schema = Pixis::Schema::Master->connection($self->dsn, $self->username, $self->password, { RaiseError => 1, AutoCommit => 1 });
    $schema->deploy({
        quote_field_names => 0,
        add_drop_table => $self->drop
    });

    foreach my $source ($schema->sources) {
        my $class = $schema->class($source);
        if (my $code = $class->can('populate_initial_data')) {
            eval {
                $code->($class, $schema);
            };
            if ($@) {
                print STDERR "Failed to load data for $source\n   $@\n";
            }
        }
    }
}

1;
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

    # I want to refacto this stuff...
    $schema->populate(
        Member => [
            [ qw(email nickname firstname lastname roles created_on) ],
            [ qw(me@mydomain admin Admin Admin), join('|', qw(admin)), DateTime->now ],
        ],
    );
    $schema->populate(
        MemberAuth => [
            [ qw(email auth_type auth_data created_on) ],
            [ qw(me@mydomain password), sha1_hex('admin'), DateTime->now ],
        ],
    );
}

1;
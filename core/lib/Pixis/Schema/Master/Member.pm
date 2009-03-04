
package Pixis::Schema::Master::Member;
use strict;
use warnings;
use base qw(Pixis::Schema::Base::MySQL);
use DateTime;

__PACKAGE__->load_components("PK::Auto", "VirtualColumns", "InflateColumn::DateTime", "Core");
__PACKAGE__->table("pixis_member");
__PACKAGE__->add_columns(
    "id" => {
        data_type => "INTEGER",
        is_auto_increment => 1,
        is_nullable => 0,
        size => 32,
    },
    email => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 256,
    },
#    password => {
#        data_type => "VARCHAR",
#        is_nullable => 0,
#        size => 128
#    },
    nickname => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 256
    },
    firstname => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 256
    },
    lastname => {
        data_type => "VARCHAR",
        is_nullable => 0,
        size => 256
    },
    roles => {
        data_type => "TEXT",
        is_nullable => 1,
    },
    coderepos_id => {
        data_type => "VARCHAR",
        is_nullable => 1,
        size => 256
    },
    cpan_id => {
        data_type => "VARCHAR",
        is_nullable => 1,
        size => 256
    },
    github_id => {
        data_type => "VARCHAR",
        is_nullable => 1,
        size => 256
    },
    country => {
        data_type => "TEXT",
        is_nullable => 1,
    },
    state   => {
        data_type => "TEXT",
        is_nullable => 1,
    },
    postal_code => { # won't bind to japanese addresses, for now
        data_type => "TEXT",
        is_nullable => 1,
    },
    address1 => { # when requiring addresses, this is required
        data_type => "TEXT",
        is_nullable => 1,
    },
    address2 => { # your town, whatever
        data_type => "TEXT",
        is_nullable => 1,
    },
    address3 => { # building name, room number, etc.
        data_type => "TEXT",
        is_nullable => 1,
    },
    activation_token => {
        data_type => "CHAR",
        is_nullable => 1,
        size => 40,
    },
    is_active => {
        data_type => 'TINYINT',
        is_nullable => 0,
        default_value => 0
    },
    modified_on => {
        data_type => "TIMESTAMP",
        is_nullable => 0,
        default_value => \'NOW()',
    },
    created_on => {
        data_type => "DATETIME",
        is_nullable => 0,
    },
);
__PACKAGE__->add_virtual_columns('password');

__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(unique_email => ['email']);
__PACKAGE__->add_unique_constraint(unique_activation_token => ['activation_token']);

sub gravatar_url {
    my $self = shift;
    my $uri  =  URI->new(sprintf("http://www.gravatar.com/avatar/%s.jpg", Digest::MD5::md5_hex($self->email)));
    $uri->query_form(@_) if @_;
    return $uri;
}

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->add_index(
        name => 'is_active_idx',
        fields => [ 'is_active' ]
    );
    my ($c) = grep { $_->name eq 'unique_email' } $sqlt_table->get_constraints();
    $c->fields([ 'email(255)' ]);
    $self->next::method($sqlt_table);
}

sub populate_initial_data {
    my ($self, $schema) = @_;
    $schema->populate(
        Member => [
            [ qw(email nickname firstname lastname is_active roles created_on) ],
            [ qw(me@example.jp admin Admin Admin 1), join('|', qw(admin)), DateTime->now ],
        ],
    );
}

1;
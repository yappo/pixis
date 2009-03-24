# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
use inc::Module::Install;
use Apache::TestMM qw(test clean);

Apache::TestMM::filter_args();
Apache::TestMM::generate_script('t/TEST');

name 'Pixis-Web';
all_from 'lib/Pixis/Web.pm';

requires 'namespace::clean';
requires 'Apache::Test';
requires 'Catalyst::Runtime' => '5.7015';
requires 'Catalyst::Controller::HTML::FormFu';
requires 'Catalyst::Authentication::Credential::Password';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Model::Data::Localize', '0.00003';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::I18N';
requires 'Catalyst::Plugin::Session';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::File';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Plugin::Unicode';
requires 'Catalyst::View::TT';
requires 'Catalyst::View::JSON';
requires 'Catalyst::View::Email';
requires 'Catalyst::Action::RenderView';
requires 'parent';
requires 'YAML'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
requires 'Cache::Memcached';
requires 'Crypt::SSLeay'; # For communication with Paypal
requires 'Data::Localize';
requires 'DateTime';
requires 'DateTime::Format::Duration';
requires 'DateTime::Format::Strptime';
requires 'DBD::mysql';
requires 'DBIx::Class';
requires 'DBIx::Class::VirtualColumns';
requires 'Digest::SHA1';
requires 'Exception::Class';
requires 'MooseX::Getopt';
requires 'MooseX::Types::Path::Class';
requires 'HTML::FormFu';
requires 'HTML::FormFu::Model::DBIC';
requires 'LWP::UserAgent'; 
requires 'Module::Pluggable';
requires 'Moose';
requires 'MooseX::AttributeHelpers';
requires 'MooseX::Types::Path::Class';
requires 'MooseX::Singleton';
requires 'MooseX::WithCache';
requires 'SQL::Translator';
requires 'Template::Provider::Encoding';

test_requires 'Test::More', '0.82';

catalyst;

tests("t/*.t t/*/*.t");
install_script glob('script/*.pl');
auto_install;
WriteAll;

print <<EOM;

HOWTO SETUP PIXIS

1. Setup your database

  To setup your database:

    # Just the core
    ./script/pixis_setupdb.pl \
        --dsn="dbi:mysql:dbname=pixis" \
        --user="...." \
        --password="..."

    # to include plugins
    ./script/pixis_cmd.pl ./script/pixis_setupdb.pl \
        --dsn="dbi:mysql:dbname=pixis" \
        --user="...." \
        --password="..."

  Add --drop, if you want to drop the old schema

    ./script/pixis_setupdb.pl ... --drop

2. Start your server

  To start your dev server

    # Just the core
    ./script/pixis_web_server.pl

    # to include plugins
    ./script/pixis_cmd.pl ./script/pixis_web_server.pl

3. To run tests

    # your regular make test:

    make test

    # or, TEST script directly

    ./t/TEST [script]

    # If you want to enable memcached

    env MEMCACHED_SERVER=127.0.0.1:11211 make test

EOM

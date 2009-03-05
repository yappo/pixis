# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
use inc::Module::Install;
# use Apache::TestMM;

# Apache::TestMM::filter_args();
# Apache::TestMM::generate_script('t/TEST');

name 'Pixis-Web';
all_from 'lib/Pixis/Web.pm';

requires 'namespace::clean';
requires 'Moose';
requires 'Catalyst::Runtime' => '5.7015';
requires 'Catalyst::Controller::HTML::FormFu';
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Authentication::Credential::Password';
requires 'Catalyst::Authentication::Store::DBIx::Class';
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
requires 'HTML::FormFu';
requires 'HTML::FormFu::Model::DBIC';
requires 'Data::Localize';
requires 'Catalyst::Model::Data::Localize', 0.00003;
requires 'DateTime';
requires 'DateTime::Format::Duration';
requires 'DBD::mysql';
requires 'DBIx::Class';
requires 'DBIx::Class::VirtualColumns';
requires 'Digest::SHA1';
requires 'MooseX::Getopt';
requires 'MooseX::Types::Path::Class';
requires 'MooseX::WithCache';
requires 'SQL::Translator';
requires 'Template::Provider::Encoding';
requires 'Module::Pluggable';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;

print <<EOM;

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

To start your dev server

    # Just the core
    ./script/pixis_web_server.pl

    # to include plugins
    ./script/pixis_cmd.pl ./script/pixis_web_server.pl

EOM

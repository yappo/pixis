# IMPORTANT: if you delete this file your app will not work as
# expected.  you have been warned
use inc::Module::Install;
# use Apache::TestMM;

# Apache::TestMM::filter_args();
# Apache::TestMM::generate_script('t/TEST');

name 'Pixis-Web';
all_from 'lib/Pixis/Web.pm';

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
requires 'Catalyst::Action::RenderView';
requires 'parent';
requires 'YAML'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported formats
requires 'HTML::FormFu';
requires 'HTML::FormFu::Model::DBIC';
requires 'Data::Localize';
requires 'Catalyst::Model::Data::Localize';
requires 'DateTime';
requires 'DBIx::Class';
requires 'DBIx::Class::VirtualColumns';
requires 'Digest::SHA1';
requires 'MooseX::WithCache';
requires 'Template::Provider::Encoding';
requires 'Module::Pluggable';

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;

# WARNING: this file is generated, do not edit
# generated on Wed Feb  4 14:45:57 2009
# 01: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestConfig.pm:955
# 02: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestConfig.pm:973
# 03: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestConfig.pm:1869
# 04: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestRun.pm:508
# 05: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestRunPerl.pm:90
# 06: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestRun.pm:725
# 07: /usr/local/lib/perl5/site_perl/5.8.8/darwin-2level/Apache/TestRun.pm:725
# 08: /Users/daisuke/svk/pixis/Pixis-Core/trunk/t/TEST:11

package apache_test_config;

sub new {
    bless( {
                 'verbose' => undef,
                 'hostport' => 'minico:8529',
                 'postamble' => [
                                  '<IfModule mod_mime.c>
    TypesConfig "/usr/local/apache/conf/mime.types"
</IfModule>
',
                                  '<IfModule mod_perl.c>
    PerlSwitches -Mlib=/Users/daisuke/svk/pixis/Pixis-Core/trunk/t
</IfModule>
',
                                  '<IfModule mod_perl.c>
    PerlRequire /Users/daisuke/svk/pixis/Pixis-Core/trunk/t/conf/modperl_startup.pl
</IfModule>
',
                                  ''
                                ],
                 'mpm' => 'prefork',
                 'inc' => [
                            '/Users/daisuke/svk/pixis/Pixis-Core/trunk/blib/lib'
                          ],
                 'APXS' => '/usr/local/apache/bin/apxs',
                 '_apxs' => {
                              'LIBEXECDIR' => '/usr/local/apache/modules',
                              'SYSCONFDIR' => '/usr/local/apache/conf',
                              'TARGET' => 'httpd',
                              'BINDIR' => '/usr/local/apache/bin',
                              'PREFIX' => '/usr/local/apache',
                              'SBINDIR' => '/usr/local/apache/bin'
                            },
                 'save' => 1,
                 'vhosts' => {},
                 'httpd_basedir' => '/usr/local/apache',
                 'server' => bless( {
                                      'run' => bless( {
                                                        'conf_opts' => {
                                                                         'verbose' => undef,
                                                                         'save' => 1
                                                                       },
                                                        'test_config' => $VAR1,
                                                        'tests' => [],
                                                        'opts' => {
                                                                    'breakpoint' => [],
                                                                    'postamble' => [],
                                                                    'preamble' => [],
                                                                    'req_args' => {},
                                                                    'header' => {}
                                                                  },
                                                        'argv' => [],
                                                        'server' => $VAR1->{'server'}
                                                      }, 'Apache::TestRunPerl' ),
                                      'port_counter' => 8529,
                                      'mpm' => 'prefork',
                                      'version' => 'Apache/2.2.6',
                                      'rev' => 2,
                                      'name' => 'minico:8529',
                                      'config' => $VAR1
                                    }, 'Apache::TestServer' ),
                 'postamble_hooks' => [
                                        'configure_inc',
                                        'configure_pm_tests_inc',
                                        'configure_startup_pl',
                                        'configure_pm_tests',
                                        sub { "DUMMY" }
                                      ],
                 'inherit_config' => {
                                       'ServerRoot' => '/usr/local/apache',
                                       'ServerAdmin' => 'you@example.com',
                                       'TypesConfig' => 'conf/mime.types',
                                       'DocumentRoot' => '/usr/local/apache/htdocs',
                                       'LoadModule' => [
                                                         [
                                                           'perl_module',
                                                           'modules/mod_perl.so'
                                                         ]
                                                       ]
                                     },
                 'cmodules_disabled' => {},
                 'preamble_hooks' => [
                                       'configure_libmodperl',
                                       'configure_env',
                                       sub { "DUMMY" }
                                     ],
                 'preamble' => [
                                 '<IfModule !mod_perl.c>
    LoadModule perl_module "/usr/local/apache/modules/mod_perl.so"
</IfModule>
',
                                 '<IfModule mod_perl.c>
    PerlPassEnv APACHE_TEST_TRACE_LEVEL
    PerlPassEnv HARNESS_PERL_SWITCHES
</IfModule>
',
                                 ''
                               ],
                 'vars' => {
                             'defines' => '',
                             'cgi_module_name' => 'mod_cgi',
                             'conf_dir' => '/usr/local/apache/conf',
                             't_conf_file' => '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t/conf/httpd.conf',
                             't_dir' => '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t',
                             'libmodperl' => '/usr/local/apache/modules/mod_perl.so',
                             'cgi_module' => 'mod_cgi.c',
                             'target' => 'httpd',
                             'thread_module' => 'worker.c',
                             'bindir' => '/usr/local/apache/bin',
                             'user' => 'daisuke',
                             'access_module_name' => 'mod_authz_host',
                             'auth_module_name' => 'mod_auth_basic',
                             'top_dir' => '/Users/daisuke/svk/pixis/Pixis-Core/trunk',
                             'httpd_conf' => '/usr/local/apache/conf/httpd.conf',
                             'httpd' => '/usr/local/apache/bin/httpd',
                             'scheme' => 'http',
                             'ssl_module_name' => 'mod_ssl',
                             'port' => 8529,
                             'sbindir' => '/usr/local/apache/bin',
                             't_conf' => '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t/conf',
                             'servername' => 'minico',
                             'inherit_documentroot' => '/usr/local/apache/htdocs',
                             'proxy' => 'off',
                             'serveradmin' => 'you@example.com',
                             'remote_addr' => '127.0.0.1',
                             'perlpod' => '/usr/local/lib/perl5/5.8.8/pods',
                             'sslcaorg' => 'asf',
                             'php_module_name' => 'sapi_apache2',
                             'maxclients_preset' => 0,
                             'php_module' => 'sapi_apache2.c',
                             'ssl_module' => 'mod_ssl.c',
                             'auth_module' => 'mod_auth_basic.c',
                             'access_module' => 'mod_authz_host.c',
                             't_logs' => '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t/logs',
                             'minclients' => 1,
                             'maxclients' => 2,
                             'group' => 'daisuke',
                             't_pid_file' => '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t/logs/httpd.pid',
                             'apxs' => '/usr/local/apache/bin/apxs',
                             'maxclientsthreadedmpm' => 2,
                             'thread_module_name' => 'worker',
                             'documentroot' => '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t/htdocs',
                             'serverroot' => '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t',
                             'sslca' => '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t/conf/ssl/ca',
                             'perl' => '/usr/local/bin/perl',
                             'src_dir' => undef,
                             'proxyssl_url' => ''
                           },
                 'clean' => {
                              'files' => {
                                           '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t/conf/modperl_inc.pl' => 1,
                                           '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t/conf/httpd.conf' => 1,
                                           '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t/logs/apache_runtime_status.sem' => 1,
                                           '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t/conf/apache_test_config.pm' => 1,
                                           '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t/conf/modperl_startup.pl' => 1,
                                           '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t/htdocs/index.html' => 1
                                         },
                              'dirs' => {
                                          '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t/logs' => 1,
                                          '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t/conf' => 1,
                                          '/Users/daisuke/svk/pixis/Pixis-Core/trunk/t/htdocs' => 1
                                        }
                            },
                 'httpd_info' => {
                                   'BUILT' => 'Nov 29 2007 18:03:41',
                                   'MODULE_MAGIC_NUMBER_MINOR' => '5',
                                   'SERVER_MPM' => 'Prefork',
                                   'VERSION' => 'Apache/2.2.6 (Unix)',
                                   'MODULE_MAGIC_NUMBER' => '20051115:5',
                                   'MODULE_MAGIC_NUMBER_MAJOR' => '20051115'
                                 },
                 'modules' => {
                                'mod_include.c' => 1,
                                'mod_asis.c' => 1,
                                'mod_env.c' => 1,
                                'mod_negotiation.c' => 1,
                                'mod_auth_basic.c' => 1,
                                'mod_authn_file.c' => 1,
                                'mod_authz_user.c' => 1,
                                'core.c' => 1,
                                'mod_authz_groupfile.c' => 1,
                                'http_core.c' => 1,
                                'mod_setenvif.c' => 1,
                                'mod_dir.c' => 1,
                                'mod_filter.c' => 1,
                                'prefork.c' => 1,
                                'mod_actions.c' => 1,
                                'mod_cgi.c' => 1,
                                'mod_authz_host.c' => 1,
                                'mod_so.c' => 1,
                                'mod_perl.c' => '/usr/local/apache/modules/mod_perl.so',
                                'mod_alias.c' => 1,
                                'mod_autoindex.c' => 1,
                                'mod_status.c' => 1,
                                'mod_authn_default.c' => 1,
                                'mod_log_config.c' => 1,
                                'mod_userdir.c' => 1,
                                'mod_authz_default.c' => 1,
                                'mod_mime.c' => 1
                              },
                 'httpd_defines' => {
                                      'SUEXEC_BIN' => '/usr/local/apache/bin/suexec',
                                      'APR_HAS_MMAP' => 1,
                                      'APR_HAS_OTHER_CHILD' => 1,
                                      'DEFAULT_PIDLOG' => 'logs/httpd.pid',
                                      'APR_USE_FLOCK_SERIALIZE' => 1,
                                      'DYNAMIC_MODULE_LIMIT' => '128',
                                      'AP_TYPES_CONFIG_FILE' => 'conf/mime.types',
                                      'DEFAULT_SCOREBOARD' => 'logs/apache_runtime_status',
                                      'DEFAULT_LOCKFILE' => 'logs/accept.lock',
                                      'APR_HAVE_IPV6 (IPv4-mapped addresses enabled)' => 1,
                                      'SINGLE_LISTEN_UNSERIALIZED_ACCEPT' => 1,
                                      'APACHE_MPM_DIR' => 'server/mpm/prefork',
                                      'DEFAULT_ERRORLOG' => 'logs/error_log',
                                      'APR_HAS_SENDFILE' => 1,
                                      'HTTPD_ROOT' => '/usr/local/apache',
                                      'AP_HAVE_RELIABLE_PIPED_LOGS' => 1,
                                      'SERVER_CONFIG_FILE' => 'conf/httpd.conf',
                                      'APR_USE_PTHREAD_SERIALIZE' => 1
                                    },
                 'apache_test_version' => '1.30'
               }, 'Apache::TestConfig' );
}

1;

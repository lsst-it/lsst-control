# @summary
#   Definition of icinga and icingaweb master module

class profile::it::icinga_master (
  $ldap_server,
  $ldap_root,
  $ldap_user,
  $ldap_pwd,
  $ldap_resource,
  $ldap_user_filter,
  $ldap_group_filter,
  $ldap_group_base,
  $ssl_name,
  $ssl_country,
  $ssl_org,
  $ssl_fqdn,
  $mysql_root,
  $mysql_icingaweb_db,
  $mysql_icingaweb_user,
  $mysql_icingaweb_pwd,
  $mysql_director_db,
  $mysql_director_user,
  $mysql_director_pwd,
  $icinga_satellite_fqdn,
  $icinga_satellite_ip,
  $salt,
  $api_name,
  $api_user,
  $api_pwd,
)
{
  include profile::core::uncommon
  include profile::core::remi
  include ::openssl
  include ::nginx

  $ssl_cert       = '/etc/ssl/certs/icinga.crt'
  $ssl_key        = '/etc/ssl/certs/icinga.key'
  $icinga_master_fqdn  = $facts[fqdn]
  $icinga_master_ip  = $facts[ipaddress]
  $php_packages = [
    'php73-php-fpm',
    'php73-php-ldap',
    'php73-php-intl',
    'php73-php-dom',
    'php73-php-gd',
    'php73-php-imagick',
    'php73-php-mysqlnd',
    'php73-php-pgsql',
    'php73-php-pdo',
    'php73-php-process',
    'php73-php-cli',
    'php73-php-soap',
    'rh-php73-php-posix',
  ]
  $override_options = {
    'mysqld' => {
      'bind_address' => '0.0.0.0',
    }
  }

##Ensure php73 packages and services
  package { $php_packages:
    ensure => 'present',
  }
  service { 'php73-php-fpm':
    ensure  => 'running',
    require => Package[$php_packages],
  }

## SSL Certificate Creation
  openssl::certificate::x509 { $ssl_name:
    country      => $ssl_country,
    organization => $ssl_org,
    commonname   => $ssl_fqdn,
  }

##MySQL definition
  class { '::mysql::server':
    root_password           => $mysql_root,
    remove_default_accounts => true,
    restart                 => true,
    override_options        => $override_options,
  }
  mysql::db { $mysql_icingaweb_db:
    user     => $mysql_icingaweb_user,
    password => $mysql_icingaweb_pwd,
    host     => $icinga_master_ip,
    grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE VIEW', 'CREATE', 'INDEX', 'EXECUTE', 'ALTER', 'REFERENCES'],
  }
  mysql::db { $mysql_director_db:
    user     => $mysql_director_user,
    password => $mysql_director_pwd,
    host     => $icinga_master_ip,
    charset  => 'utf8',
    grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE VIEW', 'CREATE', 'INDEX', 'EXECUTE', 'ALTER', 'REFERENCES'],
  }
##IcingaWeb Config
  class {'icingaweb2':
    manage_repo   => true,
    logging_level => 'DEBUG',
  }
  ->class {'icingaweb2::module::monitoring':
    ensure            => present,
    ido_host          => $icinga_master_ip,
    ido_type          => 'mysql',
    ido_db_name       => $mysql_icingaweb_db,
    ido_db_username   => $mysql_icingaweb_user,
    ido_db_password   => $mysql_icingaweb_pwd,
    commandtransports => {
      $api_name => {
        transport => 'api',
        host      => $icinga_master_ip,
        port      => 5565,
        username  => $api_user,
        password  => $api_pwd,
      }
    }
  }
##IcingaWeb LDAP Config
  ->icingaweb2::config::resource{ $ldap_resource:
    type         => 'ldap',
    host         => $ldap_server,
    port         => 389,
    ldap_root_dn => $ldap_root,
    ldap_bind_dn => $ldap_user,
    ldap_bind_pw => $ldap_pwd,
  }
  ->icingaweb2::config::authmethod { 'ldap-auth':
    backend                  => 'ldap',
    resource                 => $ldap_resource,
    ldap_user_class          => 'inetOrgPerson',
    ldap_filter              => $ldap_user_filter,
    ldap_user_name_attribute => 'uid',
    order                    => '05',
  }
  ->icingaweb2::config::groupbackend { 'ldap-groups':
    backend                   => 'ldap',
    resource                  => $ldap_resource,
    ldap_group_class          => 'groupOfNames',
    ldap_group_name_attribute => 'cn',
    ldap_group_filter         => $ldap_group_filter,
    ldap_base_dn              => $ldap_group_base,
  }
  ->icingaweb2::config::role { 'Admin User':
    groups      => 'icinga-admins',
    permissions => '*',
  }
##IcingaWeb Director
  ->class {'icingaweb2::module::director':
    git_revision  => 'v1.7.2',
    db_host       => $icinga_master_ip,
    db_name       => $mysql_director_db,
    db_username   => $mysql_director_user,
    db_password   => $mysql_director_pwd,
    import_schema => true,
    kickstart     => true,
    endpoint      => $icinga_master_fqdn,
    api_host      => $icinga_master_ip,
    api_port      => 5665,
    api_username  => $api_user,
    api_password  => $api_pwd,
    require       => Mysql::Db[$mysql_director_db],
  }
  file {'/etc/icingaweb2/':
    notify => Service['php73-php-fpm'],
  }
##IcingaWeb Daemon
# User Creation
  $command1 = 'useradd -r -g icingaweb2 -d /var/lib/icingadirector -s /bin/false icingadirector'
  $command2 = 'install -d -o icingadirector -g icingaweb2 -m 0750 /var/lib/icingadirector'
  $command3 = 'cp /usr/share/icingaweb2/modules/director/contrib/systemd/icinga-director.service /etc/systemd/system/; systemctl daemon-reload'
  $command4 = 'systemctl enable --now icinga-director.service'
  $unless1  = 'grep icingadirector /etc/passwd'
  $onlyif2  = 'test ! -d /var/lib/icingadirector'
  $onlyif3  = 'test ! -f /etc/systemd/system/icinga-director.service'
  exec { $command1:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    unless   => $unless1,
  }
# User Directory
  ->exec { $command2:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $onlyif2,
  }
# Service Creation
  ->exec { $command3:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $onlyif3,
  }
# Run and Enable Service
  service { 'icinga-director':
    ensure => running,
  }

##IcingaWeb Reactbundle
  class {'icingaweb2::module::reactbundle':
    ensure         => present,
    git_repository => 'https://github.com/Icinga/icingaweb2-module-reactbundle',
    git_revision   => 'v0.7.0',
  }
##IcingaWeb IPL
  class {'icingaweb2::module::ipl':
    ensure         => present,
    git_repository => 'https://github.com/Icinga/icingaweb2-module-ipl',
    git_revision   => 'v0.3.0'
  }
##IcingaWeb Incubator
  class {'icingaweb2::module::incubator':
    ensure         => present,
    git_repository => 'https://github.com/Icinga/icingaweb2-module-incubator',
    git_revision   => 'v0.5.0'
  }
##Icinga2 Config
  class { '::icinga2':
    manage_repo => false,
    confd       => false,
    constants   => {
      'ZoneName'   => 'master',
      'TicketSalt' => $salt,
    },
    features    => ['checker','mainlog','statusdata','compatlog','command'],
  }
  class { '::icinga2::feature::idomysql':
    user          => $mysql_icingaweb_user,
    password      => $mysql_icingaweb_pwd,
    database      => $mysql_icingaweb_db,
    host          => $icinga_master_ip,
    import_schema => true,
    require       => Mysql::Db[$mysql_icingaweb_db],
  }
  class { '::icinga2::feature::api':
    pki             => 'none',
    accept_config   => true,
    accept_commands => true,
    endpoints       => {
      $icinga_master_fqdn    => {
        'host'  =>  $icinga_master_ip
      },
      $icinga_satellite_fqdn => {
        'host'  =>  $icinga_satellite_ip,
      },
    },
    zones           => {
      'master'    => {
        'endpoints'  => [$icinga_master_fqdn],
      },
      'satellite' => {
        'endpoints' => [$icinga_satellite_fqdn],
        'parent'    => 'master',
      },
    },
  }
  include ::icinga2::pki::ca
  class { '::icinga2::feature::notification':
    ensure    => present,
    enable_ha => true,
  }
  icinga2::object::apiuser { $api_user:
    ensure      => present,
    password    => $api_pwd,
    permissions => [ 'status/query', 'actions/*', 'objects/modify/*', 'objects/query/*' ],
    target      => '/etc/icinga2/features-enabled/api-users.conf',
  }
  icinga2::object::zone { 'global-templates':
    global => true,
  }
  exec { 'Icinga Director DB migration':
    path    => '/usr/local/bin:/usr/bin:/bin',
    command => 'icingacli director migration run',
    onlyif  => 'icingacli director migration pending',
  }
  exec { 'Icinga Director Kickstart':
    path    => '/usr/local/bin:/usr/bin:/bin',
    command => 'icingacli director kickstart run',
    onlyif  => 'icingacli director kickstart required',
    require => Exec['Icinga Director DB migration'],
  }

##Nginx Resource Definition
  nginx::resource::server { 'icingaweb2':
    server_name          => [$ssl_fqdn],
    ssl                  => true,
    ssl_cert             => $ssl_cert,
    ssl_key              => $ssl_key,
    ssl_redirect         => true,
    index_files          => ['index.php'],
    use_default_location => false,
    www_root             => '/usr/share/icingaweb2/public',
  }
  nginx::resource::location { 'root':
    location    => '/',
    server      => 'icingaweb2',
    try_files   => ['$1', '$uri', '$uri/', '/index.php$is_args$args'],
    index_files => [],
    ssl         => true,
    ssl_only    => true,
  }
  nginx::resource::location { 'icingaweb':
    location       => '~ ^/icingaweb2(.+)?',
    location_alias => '/usr/share/icingaweb2/public',
    try_files      => ['$1', '$uri', '$uri/', '/icingaweb2/index.php$is_args$args'],
    index_files    => ['index.php'],
    server         => 'icingaweb2',
    ssl            => true,
    ssl_only       => true,
  }
  nginx::resource::location { 'icingaweb2_index':
    location      => '~ ^/index\.php(.*)$',
    server        => 'icingaweb2',
    ssl           => true,
    ssl_only      => true,
    index_files   => [],
    try_files     => ['$uri =404'],
    fastcgi       => '127.0.0.1:9000',
    fastcgi_index => 'index.php',
    fastcgi_param => {
      'ICINGAWEB_CONFIGDIR' => '/etc/icingaweb2',
      'REMOTE_USER'         => '$remote_user',
      'SCRIPT_FILENAME'     => '/usr/share/icingaweb2/public/index.php',
    },
  }
}

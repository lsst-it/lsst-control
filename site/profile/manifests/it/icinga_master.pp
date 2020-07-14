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
  $mysql_db,
  $mysql_user,
  $mysql_pwd,
  $icinga_satellite,
  $salt,
)
{
  include profile::core::uncommon
  include profile::core::remi
  include ::openssl
  include ::nginx
  include ::mysql::server
  include ::icinga2
  include ::icinga2::repo
  include ::icinga2::pki::ca
  include ::icingaweb2

  $ssl_cert       = '/etc/ssl/certs/icinga.crt'
  $ssl_key        = '/etc/ssl/certs/icinga.key'

## SSL Certificate Creation
  openssl::certificate::x509 { $ssl_name:
    country      => $ssl_country,
    organization => $ssl_org,
    commonname   => $ssl_fqdn,
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
##MySQL definition
  mysql::db { $mysql_db:
    user     => $mysql_user,
    password => $mysql_pwd,
    host     => 'localhost',
    grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE VIEW', 'CREATE', 'INDEX', 'EXECUTE', 'ALTER', 'REFERENCES'],
  }

##IcingaWeb Config
  class {'icingaweb2::module::monitoring':
    ido_host          => 'localhost',
    ido_db_name       => $mysql_db,
    ido_db_username   => $mysql_user,
    ido_db_password   => $mysql_pwd,
    commandtransports => {
      icinga2 => {
        transport => 'api',
        username  => 'root',
        password  => 'icinga',
      }
    }
  }

##Icinga2 Config
  class { '::icinga2::feature::idomysql':
        user          => $mysql_user,
        password      => $mysql_pwd,
        database      => $mysql_db,
        import_schema => true,
  }
  class { '::icinga2::feature::api':
    pki             => 'none',
    accept_commands => true,
    ca_host         => $facts['ipaddress'],
    ticket_salt     => $salt,
    endpoints       => {
      $facts['fqdn']    => {},
      $icinga_satellite => {},
    },
    zones           => {
      'master'    => {
        'endpoints' => [$facts['fqdn']],
      },
      'satellite' => {
        'endpoints' => [$icinga_satellite],
        'parent'    => 'master',
      },
    },
  }
  icinga2::object::zone { 'global-templates':
    global => true,
  }

##IcingaWeb LDAP Config
  icingaweb2::config::resource{ $ldap_resource:
    type         => 'ldap',
    host         => $ldap_server,
    port         => 389,
    ldap_root_dn => $ldap_root,
    ldap_bind_dn => $ldap_user,
    ldap_bind_pw => $ldap_pwd,
  }
  icingaweb2::config::authmethod { 'ldap-auth':
    backend                  => 'ldap',
    resource                 => $ldap_resource,
    ldap_user_class          => 'inetOrgPerson',
    ldap_filter              => $ldap_user_filter,
    ldap_user_name_attribute => 'uid',
    order                    => '05',
  }
  icingaweb2::config::groupbackend { 'ldap-groups':
    backend                   => 'ldap',
    resource                  => $ldap_resource,
    ldap_group_class          => 'groupOfNames',
    ldap_group_name_attribute => 'cn',
    ldap_group_filter         => $ldap_group_filter,
    ldap_base_dn              => $ldap_group_base,
  }
  icingaweb2::config::role { 'Admin User':
    groups      => 'icinga-admins',
    permissions => '*',
  }
}

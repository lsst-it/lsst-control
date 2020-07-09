# @summary
#   Ensure icinga2.conf file

class profile::core::icinga2conf
{
  include '::apache'
  include '::apache::mod::proxy'
  include '::apache::mod::proxy_fcgi'
  include '::apache::mod::ssl'
  include '::icinga2'
  include '::icinga2::pki::ca'
  include '::icingaweb2'
  include '::mysql::server'

  ::apache::namevirtualhost { '*:443': }
  ::apache::listen { '443': }

class { '::icinga2::feature::api':
  pki             => 'none',
  accept_commands => true,
  accept_config   => true,
  endpoints       => {
    'it-icinga.ls.lsst.org' => {},
  },
  zones           => {
    'master' => {
      'endpoints' => ['it-icinga.ls.lsst.org'],
    },
  }
}

icinga2::object::zone { 'global-templates':
  global => true,
}

icingaweb2::config::resource{ 'rubinobs':
  type         => 'ldap',
  host         => '139.229.135.6',
  port         => 389,
  ldap_root_dn => 'cn=accounts,dc=lsst,dc=cloud',
  ldap_bind_dn => 'uid=svc_icinga,cn=users,cn=accounts,dc=lsst,dc=cloud',
  ldap_bind_pw => 'um0l7BmP;$WU',
}

icingaweb2::config::authmethod { 'ldap-auth':
  backend                  => 'ldap',
  resource                 => 'rubinobs',
  ldap_user_class          => 'inetOrgPerson',
  ldap_filter              => '(memberof=cn=icinga-admins,cn=groups,cn=accounts,dc=lsst,dc=cloud)',
  ldap_user_name_attribute => 'uid',
  order                    => '05',
}

icingaweb2::config::groupbackend { 'ldap-groups':
  backend                   => 'ldap',
  resource                  => 'rubinobs',
  ldap_group_class          => 'groupOfNames',
  ldap_group_name_attribute => 'cn',
  ldap_group_filter         => 'cn=icinga-*',
  ldap_base_dn              => 'cn=groups,cn=accounts,dc=lsst,dc=cloud',
}

icingaweb2::config::role { 'Admin User':
  groups      => 'icinga-admins',
  permissions => '*',
}

class {'icingaweb2::module::monitoring':
  ido_host          => 'localhost',
  ido_db_name       => 'icinga2',
  ido_db_username   => 'icinga2',
  ido_db_password   => 'supersecret',
  commandtransports => {
    icinga2 => {
      transport => 'api',
      username  => 'icingaweb2',
      password  => 'supersecret',
    }
  }
}
  file { '/etc/httpd/conf.d/icingaweb2.conf':
    ensure => file,
    source => 'puppet:///modules/icingaweb2/examples/apache2/for-mod_proxy_fcgi.conf',
    notify => Service['httpd'],
  }
}

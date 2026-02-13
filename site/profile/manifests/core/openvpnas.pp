# @summary
#   Installs and configures OpenVPN Access Server with LDAP authentication and group setup.
#
# @param version
#   Sets version lock for OpenVPN package.
#
# @param bind_pw
#   Optional. LDAP bind password for OpenVPN Access Server.
#
# @param vpn_groups
#   Hash of VPN groups to create with their properties.
#   Example: { 'vpn-it' => { 'superuser' => true }, 'vpn-default' => { 'superuser' => false } }
#
class profile::core::openvpnas (
  String[1] $version,
  Optional[String[1]] $bind_pw = undef,
  Hash[String, Hash] $vpn_groups = {},
) {
  include profile::core::letsencrypt
  $fqdn    = $facts['networking']['fqdn']
  $le_root = "/etc/letsencrypt/live/${fqdn}"
  $ldap_pw = pick($bind_pw, 'testpassword')
  $sacli   = '/usr/local/openvpn_as/scripts/sacli'

  letsencrypt::certonly { $fqdn:
    plugin      => 'dns-route53',
    manage_cron => true,
  }

  class { 'openvpnas':
    manage_repo         => true,
    version             => $version,
    versionlock_enable  => true,
    versionlock_release => '1.el9',
    manage_service      => true,
    manage_web_certs    => true,
    cert_source_path    => $le_root,
    require             => Letsencrypt::Certonly[$fqdn],
  }

  # LDAP Configuration
  openvpnas::config::key { 'auth.ldap.0.server.0.host':
    key   => 'auth.ldap.0.server.0.host',
    value => 'ipa1.cp.lsst.org',
  }
  openvpnas::config::key { 'auth.ldap.0.server.1.host':
    key   => 'auth.ldap.0.server.1.host',
    value => 'ipa1.ls.lsst.org',
  }
  openvpnas::config::key { 'auth.ldap.0.bind_dn':
    key   => 'auth.ldap.0.bind_dn',
    value => 'uid=svc_openvpnas,cn=users,cn=accounts,dc=lsst,dc=cloud',
  }
  openvpnas::config::key { 'auth.ldap.0.bind_pw':
    key   => 'auth.ldap.0.bind_pw',
    value => $ldap_pw,
  }
  openvpnas::config::key { 'auth.ldap.0.enable':
    key   => 'auth.ldap.0.enable',
    value => true,
  }
  openvpnas::config::key { 'auth.ldap.0.users_base_dn':
    key   => 'auth.ldap.0.users_base_dn',
    value => 'cn=accounts,dc=lsst,dc=cloud',
  }
  openvpnas::config::key { 'auth.ldap.0.add_req':
    key   => 'auth.ldap.0.add_req',
    value => 'memberOf=cn=vpn,cn=groups,cn=accounts,dc=lsst,dc=cloud',
  }
  openvpnas::config::key { 'auth.ldap.0.uname_attr':
    key   => 'auth.ldap.0.uname_attr',
    value => 'uid',
  }
  openvpnas::config::key { 'auth.module.type':
    key   => 'auth.module.type',
    value => 'ldap',
  }

  # GROUP CREATION - Loop through groups from Hiera
  $vpn_groups.each |String $group_name, Hash $group_config| {
    openvpnas::config::group { $group_name:
      user      => $group_name,
      superuser => $group_config['superuser'],
    }
  }

  # Build list of group requirements for post-auth script
  $group_requirements = $vpn_groups.keys.map |$group| {
    Openvpnas::Config::Group[$group]
  }

  # POST-AUTH PYTHON SCRIPT
  $file = 'ldap.py'
  file { "/root/${file}":
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => "puppet:///modules/${module_name}/openvpnas/${file}",
  }

  exec { 'install post-auth script':
    command     => "${sacli} -k auth.module.post_auth_script --value_file=/root/ldap.py ConfigPut && ${sacli} start",
    refreshonly => true,
    subscribe   => File['/root/ldap.py'],
    path        => ['/usr/local/openvpn_as/scripts', '/usr/bin', '/bin'],
    require     => $group_requirements + [Openvpnas::Config::Key['auth.module.type']],
  }
}

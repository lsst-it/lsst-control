# @summary
#   Install and manage Duo 2fa proxy

class profile::core::duo (
  String $ikey_ds,
  String $ikey_app,
  String $skey_ds,
  String $skey_app,
  String $api,
  String $ldap_server,
  String $ldap_user,
  String $ldap_pwd,
  String $ldap_basedn
) {
  #  Duo Archive Variables
  $source_name    = 'duoauthproxy'
  $install_path   = "/opt/${source_name}_src"
  $package_ensure = 'latest-src'
  $repository_url = 'https://dl.duosecurity.com'
  $package_name   = "${source_name}-${package_ensure}.tgz"
  $package_source = "${repository_url}/${package_name}"

  #  Yum list packages
  $yum_packages = [
    'gcc',
    'make',
    'libffi-devel',
    'perl',
    'zlib-devel',
    'diffutils',
  ]
  #  Duo Installation Script
  $duo_install = @("DUO_INSTALL")
    cd ${install_path}
    make
    echo $? > ${install_path}/status
    |DUO_INSTALL
  #  Duo Setup Content
  $duo_setup = @("DUO_SETUP")
    [ad_client]
    host=${ldap_server}
    auth_type=plain
    bind_dn=${ldap_user}
    service_account_username=${ldap_user}
    service_account_password=${ldap_pwd}
    search_dn=${ldap_basedn}
    username_attribute=uid
    transport=ldaps
    ssl_ca_certs_file=/etc/ipa/ca.crt
    ssl_verify_hostname=false
    [ldap_server_auto]
    ikey=${ikey_app}
    skey=${skey_app}
    api_host=${api}
    failmode=safe
    client=ad_client
    port=389
    [cloud]
    ikey=${ikey_ds}
    skey=${skey_ds}
    api_host=${api}
    service_account_username=${ldap_user}
    service_account_password=${ldap_pwd}
    |DUO_SETUP
  #  Install Duo packages requirement
  package { $yum_packages:
    ensure => 'present'
  }
  #  Create Duo Directory
  file { $install_path:
    ensure => directory,
  }
  #  Fetch and untar duosecurity
  -> archive { $package_name:
    path            => "/tmp/${package_name}",
    source          => $package_source,
    extract         => true,
    extract_path    => '/opt',
    extract_command => "tar zxf %s -C ${install_path} --strip-components=1",
    cleanup         => true,
    require         => Package[$yum_packages],
  }
  #  Duo Installation
  -> exec { $duo_install:
    cwd      => '/opt',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    unless   => "test -d ${install_path}/duoauthproxy-build",
    loglevel => debug,
  }
  #  Create authproxy.cfg
  file { '/opt/duoauthproxy/conf/authproxy.cfg':
    ensure  => 'present',
    mode    => '0640',
    owner   => 'duo_authproxy_svc',
    content => $duo_setup,
  }
  #  Open ports 389 and 636 for Duo App
  firewalld_port { 'Enable 389 for ldap':
    ensure   => present,
    zone     => 'dmz',
    port     => 389,
    protocol => 'tcp',
  }
  firewalld_port { 'Enable 636 for ldap':
    ensure   => present,
    zone     => 'dmz',
    port     => 636,
    protocol => 'tcp',
  }
}

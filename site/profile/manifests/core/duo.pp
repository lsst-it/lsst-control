# @summary
#   Install and manage Duo 2fa proxy

class profile::core::duo (
  String $ikey,
  String $skey,
  String $api,
  String $ldap_server,
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
  #  Duo Setup Script
  $duo_setup = @("DUO_SETUP")
    [ad_client]
    host=
    service_account_username=
    service_account_password=
    search_dn=
    [radius_server_auto]
    ikey=
    skey=
    api_host=
    radius_ip_1=
    radius_secret_1=
    failmode=safe
    client=ad_client
    port=1812
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
    protocol => 'udp',
  }
}

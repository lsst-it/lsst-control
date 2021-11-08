# @summary
#   Install and manage Duo 2fa proxy

class profile::core::duo (
  String $ikey,
  String $skey,
  String $api,
) {
  #  Duo Archive Variables
  $source_name    = 'duoauthproxy'
  $install_path   = "/opt/${source_name}"
  $package_ensure = '5.5.0-src'
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
}

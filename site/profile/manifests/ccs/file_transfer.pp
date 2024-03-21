# @summary
#   Install items related to ccs file transfer.
#
# @param directory
#   String specifying directory to install to.
# @param user
#   String specifying user to install as
# @param group
#   String specifying group to install as
# @param repo_directory
#   String specifying directory to install git repo to
# @param repo_url
#   String specifying git repo to install
# @param repo_ref
#   String specifying git revision to install
# @param secret
#   String specifying authorization string
# @param secret_file
#   String specifying file to write secret to
# @param pkgurl
#   String specifying url to fetch binaries from
# @param pkgurl_user
#   String specifying username for pkgurl
# @param pkgurl_pass
#   String specifying password for pkgurl
#
class profile::ccs::file_transfer (
  String $directory = '/home/ccs-ipa/bin',
  String $user  = 'ccs-ipa',
  String $group = 'ccs-ipa',
  String $repo_directory = '/home/ccs-ipa/file-transfer',
  String $repo_url = 'https://github.com/lsst-camera-dh/ccs-data-transfer',
  String $repo_ref = 'main',
  String $secret = "export MC_HOST_oga=localhost\n",
  String $secret_file = 'mc-secret',
  String $pkgurl = $profile::ccs::common::pkgurl,
  String $pkgurl_user = $profile::ccs::common::pkgurl_user,
  String $pkgurl_pass = $profile::ccs::common::pkgurl_pass,
) {
  file { $directory:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }

  file { "${directory}/${secret_file}":
    content => "${secret}\n",
    owner   => $user,
    group   => $group,
    mode    => '0600',
    require => File[$directory],
  }

  $binary_files = ['fhe', 'mc']

  $binary_files.each | String $binfile | {
    archive { "/var/tmp/${binfile}":
      ensure   => present,
      source   => "${pkgurl}/${binfile}",
      username => $pkgurl_user,
      password => $pkgurl_pass,
    }
    file { "${directory}/${binfile}":
      ensure  => file,
      source  => "/var/tmp/${binfile}",
      owner   => $user,
      group   => $group,
      mode    => '0755',
      require => File[$directory],
    }
  }

  vcsrepo { $repo_directory:
    ensure   => present,
    provider => git,
    source   => $repo_url,
    revision => $repo_ref,
    user     => $user,
    owner    => $user,
    group    => $group,
  }

  $script_files = ['ccs-push', 'compress', 'fpack-in-place', 'push-usdf']
  $script_files.each | String $scriptfile | {
    file { "${directory}/${scriptfile}":
      ensure  => link,
      target  => "${repo_directory}/${scriptfile}",
      owner   => $user,
      group   => $group,
      require => File[$directory],
    }
  }
}

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
  Sensitive[String[1]] $secret = "export MC_HOST_oga=localhost\n",
  String $secret_file = 'mc-secret',
  String $pkgurl = $profile::ccs::common::pkgurl,
  Variant[Sensitive[String[1]],String[1]] $pkgurl_user = $profile::ccs::common::pkgurl_user,
  Sensitive[String[1]] $pkgurl_pass = $profile::ccs::common::pkgurl_pass,
) {
  $parent = "${dirname($directory)}"

  ensure_resource('file', $parent, {
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  })

  file { $directory:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }

  file { "${directory}/${secret_file}":
    content => "${secret.unwrap}\n",
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
      username => $pkgurl_user.unwrap,
      password => $pkgurl_pass.unwrap,
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
    ensure   => latest,
    provider => git,
    source   => $repo_url,
    revision => $repo_ref,
    user     => $user,
    owner    => $user,
    group    => $group,
  }

  $script_files = [
    'ccs-push',
    'compress',
    'fpack-in-place',
    'generate-sidecar',
    'push-additional-oods',
    'push-additional-usdf',
    'push-oods',
    'push-usdf',
    'send-s3nd',
  ]
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

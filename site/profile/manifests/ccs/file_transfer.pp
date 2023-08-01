# @summary
#   Install items related to ccs file transfer.
#
# @param install
#   Boolean, false means do nothing.
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
#
class profile::ccs::file_transfer (
  Boolean $install = false,
  String $directory = '/home/ccs-ipa/bin',
  String $user  = 'ccs-ipa',
  String $group = 'ccs-ipa',
  String $repo_directory = '/home/ccs-ipa/file-transfer',
  String $repo_url = 'https://github.com/lsst-camera-dh/ccs-data-transfer',
  String $repo_ref = 'main',
  String $secret = "export MC_HOST_oga=localhost\n",
  String $secret_file = 'mc-secret',
) {
  if $install {
    file { $directory:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0755',
    }

    file { "${directory}/${secret_file}":
      content => $secret,
      owner   => $user,
      group   => $group,
      mode    => '0600',
      require => File[$directory],
    }

    $binary_files = ['fhe', 'mc']

    $binary_files.each | String $binfile | {
      archive { "/var/tmp/${binfile}":
        ensure   => present,
        source   => "${profile::ccs::common::pkgurl}/${binfile}",
        username => $profile::ccs::common::pkgurl_user,
        password => $profile::ccs::common::pkgurl_pass,
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
}

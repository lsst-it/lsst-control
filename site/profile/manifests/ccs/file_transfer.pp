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
# @param s3daemon
#   Boolean, true to install s3daemon
# @param s3daemon_repo_url
#   URL of the s3daemon repo
# @param s3daemon_repo_rev
#   Git repository revision of s3daemon to install
# @param s3daemon_repo_directory
#   String specifying s3daemon installation directory
# @param s3daemon_env_file
#   String specifying s3daemon environment file
# @param s3daemon_env_url
#   String giving s3daemon endpoint URL
# @param s3daemon_env_access
#   String giving s3daemon access key
# @param s3daemon_env_secret
#  String giving s3daemon secret key
#
class profile::ccs::file_transfer (
  String[1] $s3daemon_env_access,
  String[1] $s3daemon_env_secret,
  Boolean $s3daemon = false,
  Stdlib::HTTPUrl $s3daemon_repo_url = 'https://github.com/lsst-dm/s3daemon',
  Optional[String[1]] $s3daemon_repo_rev = undef,
  String $s3daemon_repo_directory = '/home/ccs-ipa/s3daemon/git',
  String $s3daemon_env_file = '/home/ccs-ipa/s3daemon/env',
  String $s3daemon_env_url = 'https://s3dfrgw.slac.stanford.edu',
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
  ## We expect that s3daemon will become the default (and only) method
  ## some time soonish.
  if $s3daemon {
    case fact('os.release.major') {
      '7': {
        $pip_extra_packages = [
          'aiosignal',
          'async-timeout',
          'attrs',
          'charset-normalizer',
          'multidict',
          'typing_extensions',
          'yarl',
        ]
        $yum_extra_packages = []
      }
      '8': {
        $pip_extra_packages = [
          'aiosignal',
        ]
        $yum_extra_packages = [
          'python3-async-timeout',
          'python3-attrs',
          'python3-charset-normalizer',
          'python3-multidict',
          'python3-typing-extensions',
          'python3-yarl',
        ]
      }
      default: {
        $pip_extra_packages = []
        $yum_extra_packages = [
          'python3-aiosignal',
          'python3-async-timeout',
          'python3-attrs',
          'python3-charset-normalizer',
          'python3-multidict',
          'python3-typing-extensions',
          'python3-yarl',
        ]
      }
    }

    $yum_packages = $yum_extra_packages + [
      'python3',
      'python3-pip',
      'python3-devel',
    ]

    $pip_packages = $pip_extra_packages + [
      'idna_ssl',
      'aiobotocore',
    ]

    package { $yum_packages:
      ensure => 'present',
    }

    package { $pip_packages:
      ensure   => 'present',
      provider => 'pip3',
    }

    $repo_parent = "${dirname($s3daemon_repo_directory)}"
    $env_parent = "${dirname($s3daemon_env_file)}"

    $parents = [$repo_parent, $env_parent]

    $parents.unique.each | String $direc | {
      file { $direc:
        ensure => directory,
        mode   => '0755',
        owner  => $user,
        group  => $group,
      }
    }

    $envfile_epp_vars = {
      url    => $s3daemon_env_url,
      access => $s3daemon_env_access,
      secret => $s3daemon_env_secret,
    }

    file { $s3daemon_env_file:
      content => epp("${module_name}/ccs/file_transfer/s3daemon_envfile.epp", $envfile_epp_vars),
      owner   => $user,
      group   => $group,
      mode    => '0600',
      require => File[$env_parent],
    }

    vcsrepo { $s3daemon_repo_directory:
      ensure   => latest,
      provider => git,
      source   => $s3daemon_repo_url,
      revision => $s3daemon_repo_rev,
      user     => $user,
      require  => File[$repo_parent],
    }

    $epp_vars = {
      desc    => 's3daemon file transfer service',
      user    => $user,
      group   => $group,
      cmd     => "/usr/bin/python3 ${s3daemon_repo_directory}/python/s3daemon/s3daemon.py",
      workdir => "/home/${user}",
      envfile => $s3daemon_env_file,
    }

    systemd::unit_file { 's3daemon.service':
      content => epp("${module_name}/ccs/service.epp", $epp_vars),
    }
    ~> service { 's3daemon':
      ensure => 'running',
      enable => true,
    }
  }                           # s3daemon

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

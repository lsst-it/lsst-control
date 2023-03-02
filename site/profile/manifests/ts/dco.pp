# @summary
#   Setups the `dco` user with the `docker-compose-ops` git repo
#
class profile::ts::dco {
  $user = 'dco'

  file { "/home/${user}/docker_tmp":
    ensure => directory,
    mode   => '0777',
    owner  => $user,
    group  => $user,
  }

  vcsrepo { "/home/${user}/docker-compose-ops":
    ensure             => present,
    provider           => git,
    source             => 'https://github.com/lsst-it/docker-compose-ops.git',
    keep_local_changes => true,
    user               => $user,
    owner              => $user,
    group              => $user,
  }

  vcsrepo { "/home/${user}/ts_ddsconfig":
    ensure             => present,
    provider           => git,
    source             => 'https://github.com/lsst-ts/ts_ddsconfig.git',
    keep_local_changes => true,
    user               => $user,
    owner              => $user,
    group              => $user,
  }
}

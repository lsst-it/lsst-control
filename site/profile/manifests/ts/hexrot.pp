# @summary
# Sets up repos and symlinks for hexrot

class profile::ts::hexrot {
  vcsrepo { '/opt/ts_config_mttcs':
    ensure             => present,
    provider           => git,
    source             => 'https://github.com/lsst-ts/ts_config_mttcs.git',
    revision           => 'v0.12.8',
    keep_local_changes => false,
  }
  file { '/etc/profile.d/hexrot_path.sh':
    ensure  => file,
    mode    => '0644',
    # lint:ignore:strict_indent
    content => @(ENV),
        export QT_API="PySide6"
        export PYTEST_QT_API="PySide6"
        export TS_CONFIG_MTTCS_DIR="/opt/ts_config_mttcs"
        | ENV
    # lint:endignore
    require => Vcsrepo['/opt/ts_config_mttcs'],
  }
  file { '/rubin/mtm2/python':
    ensure => directory,
    owner  => 73006,
    group  => 73006,
  }
  file { '/rubin/mtm2/python/run_m2gui':
    ensure => link,
    owner  => 73006,
    group  => 73006,
    target => '/opt/anaconda/envs/py311/bin/run_m2gui',
  }
  file { ['/rubin/rotator', '/rubin/hexapod', '/rubin/mtm2']:
    ensure  => directory,
    owner   => 73006,
    group   => 73006,
    recurse => true,
  }
  file { ['/rubin/rotator/log', '/rubin/hexapod/log', '/rubin/mtm2/log']:
    ensure => directory,
    owner  => 73006,
    group  => 73006,
    mode   => '0775',
  }
}

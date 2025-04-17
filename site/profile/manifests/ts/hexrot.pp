# @summary
# Sets up repos and symlinks for hexrot
# @param ts_config_mttcs_version
#   sets the repo version of the config
class profile::ts::hexrot (
  String $ts_config_mttcs_version,
) {
  vcsrepo { '/opt/ts_config_mttcs':
    ensure             => present,
    provider           => git,
    source             => 'https://github.com/lsst-ts/ts_config_mttcs.git',
    revision           => $ts_config_mttcs_version,
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
  file { ['/rubin/mtm2/python', '/rubin/rotator/python', '/rubin/hexapod/python', '/rubin/dome/python']:
    ensure => directory,
    owner  => 73006,
    group  => 73006,
  }

  $symlinks = {
    '/rubin/mtm2/python/run_m2gui'     => '/opt/anaconda/envs/py311/bin/run_m2gui',
    '/rubin/hexapod/python/run_hexgui' => '/opt/anaconda/envs/py311/bin/run_hexgui',
    '/rubin/dome/python/run_mtdomegui' => '/opt/anaconda/envs/py311/bin/run_mtdomegui',
    '/rubin/rotator/python/run_rotgui' => '/opt/anaconda/envs/py311/bin/run_rotgui',
  }

  $symlinks.each |$source, $target| {
    file { $source:
      ensure => link,
      owner  => 73006,
      group  => 73006,
      target => $target,
    }
  }

  file { ['/rubin/rotator', '/rubin/hexapod', '/rubin/mtm2', '/rubin/dome']:
    ensure  => directory,
    owner   => 73006,
    group   => 73006,
    recurse => true,
  }
  file { ['/rubin/rotator/log', '/rubin/hexapod/log', '/rubin/mtm2/log', '/rubin/dome/log']:
    ensure => directory,
    owner  => 73006,
    group  => 73006,
    mode   => '0775',
  }
}

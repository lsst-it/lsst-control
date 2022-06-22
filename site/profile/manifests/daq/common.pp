# @summary
#   Common functionality needed by daq nodes.
#
class profile::daq::common {
  file { [
      '/srv',
      '/srv/nfs',
      '/srv/nfs/lsst-daq',
      '/srv/nfs/lsst-daq/daq-sdk',
    ]:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
  }

  mount { '/srv/nfs/lsst-daq/daq-sdk':
    ensure  => 'mounted',
    device  => '/opt/lsst/daq-sdk',
    fstype  => 'none',
    options => 'defaults,bind',
    require => File['/srv/nfs/lsst-daq/daq-sdk'],  # mount will autorequire the device
  }
}

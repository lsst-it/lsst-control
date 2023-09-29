# @summary
#   Install a forked version of the fog-libvirt gem that supports the q35
#   machine type, which is required by EL9.
#
#   This hack should be removed after the
#   https://github.com/fog/fog-libvirt/pull/127 PR is merged and a new stable
#   release of fog-libvirt is made.
#
class profile::core::foreman::fog_hack {
  ensure_packages(['libvirt-devel'])

  archive { 'fog-libvirt-0.11.0.gem':
    ensure => present,
    path   => '/tmp/fog-libvirt-0.11.0.gem',
    source => 'https://github.com/lsst-it/fog-libvirt/releases/download/v0.11.0/fog-libvirt-0.11.0.gem',
  }
  ~> exec { 'install-fog-libvirt.0.11.0.gem':
    command     => '/usr/bin/scl enable rh-ruby27 tfm -- gem install /tmp/fog-libvirt-0.11.0.gem',
    path        => '/usr/bin:/bin',
    refreshonly => true,
    require     => Package['libvirt-devel'],
  }
}

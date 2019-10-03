class profile::core::libvirt {
  # XXX add support to libvirt to configure pools via hiera
  libvirt_pool { 'default' :
    ensure    => present,
    active    => true,
    autostart => true,
    type      => 'dir',
    target    => '/vm',
  }
}

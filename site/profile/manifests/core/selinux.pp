class profile::core::selinux {
  Class['selinux::config']
  ~> reboot { 'disable selinux':
    apply   => finished,
    message => 'disable selinux',
    when    => refreshed,
  }
}

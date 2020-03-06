class profile::core::selinux {
  if ($facts['os']['selinux']['enabled']) {
    notify { "os.selinux.enabled == ${facts['os']['selinux']['enabled']}":
      notify => Reboot['selinux'],
    }
  }

  Class['selinux::config']
  ~> reboot { 'selinux':
    apply   => finished,
    message => 'disable selinux',
    when    => refreshed,
  }
}

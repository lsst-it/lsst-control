class profile::core::selinux {
  if fact('os.selinux.enabled') {
    notify { "os.selinux.enabled == ${fact('os.selinux.enabled')}":
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

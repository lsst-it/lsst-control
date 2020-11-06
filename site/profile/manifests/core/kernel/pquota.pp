class profile::core::kernel::pquota {
  kernel_parameter { 'rootflags=pquota':
    ensure => present,
  }
  ~> reboot { 'rootfs xfs pquota':
    apply   => finished,
    message => 'enable rootfs xfs pquota',
    when    => refreshed,
  }
}

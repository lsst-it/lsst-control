class profile::core::kernel (
  $version,
) {
  include yum::plugin::versionlock

  $k      = "kernel-${version}"
  $kt     = "kernel-tools-${version}"
  $ktlibs = "kernel-tools-libs-${version}"
  yum::versionlock { [
    "0:${k}",
    "0:${kt}",
    "0:${ktlibs}",
  ]:
    ensure => present,
  }

  # reboot if changing the kernel version
  package { 'kernel':
    ensure => $version,
    notify => Reboot['kernel version'],
  }

  # do not trigger a reboot for the tools packages
  # XXX yum downgrading is still broken
  #package { ['kernel-tools', 'kernel-tools-libs']:
  #  ensure => $version,
  #}

  # sanity check booted kernel
  unless ($::kernelrelease == $version) {
    notify { "system is running ${::kernelrelease}, desrired version is ${version}":
      notify => Reboot['kernel version'],
    }
  }

  reboot { 'kernel version':
    apply   => finished,
    message => 'changing running kernel',
    when    => refreshed,
  }
}

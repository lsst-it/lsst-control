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
    ensure => present,
    name   => $k,
    notify => Reboot['kernel version'],
  }

  # do not trigger a reboot for the tools packages
  # XXX yum downgrading is still broken
  #package { ['kernel-tools', 'kernel-tools-libs']:
  #  ensure => $version,
  #}

  if $facts['augeasprovider_grub_version'] != 2 {
    # the augeas grub2 provider does not work on EFI systems!
    # https://github.com/hercules-team/augeasproviders_grub/blob/3.1.0/lib/puppet/provider/grub_config/grub2.rb#L76
    grub_config { 'GRUB_DEFAULT':
      ensure   => present,
      value    => "vmlinuz-${version}",
      notify   => Reboot['kernel version'],
      provider => 'grub2',
    }
  }

  # sanity check booted kernel
  unless ($facts['kernelrelease'] == $version) {
    notify { "system is running ${facts['kernelrelease']}, desrired version is ${version}":
      notify => Reboot['kernel version'],
    }
  }

  reboot { 'kernel version':
    apply   => finished,
    message => 'changing running kernel',
    when    => refreshed,
  }
}

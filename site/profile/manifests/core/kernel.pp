# @summary
#   versionlock kernel packages
#
# @param version
#   kernel version string
#
# @param devel
#   if true, install kernel-devel package
#
# @param debuginfo
#   if true, install kernel-debuginfo package
#
class profile::core::kernel (
  Optional[String] $version = undef,
  Boolean $devel            = false,
  Boolean $debuginfo        = false,
) {
  include yum::plugin::versionlock

  if $version {
    yum::versionlock { [
        'kernel',
        'kernel-tools',
        'kernel-tools-libs',
      ]:
        ensure  => present,
        version => $version,
    }

    if $devel {
      yum::versionlock { 'kernel-devel':
        ensure  => present,
        version => $version,
      }

      # reboot is not needed for -devel
      package { 'kernel-devel':
        ensure  => present,
        name    => "kernel-devel-${version}",
        require => Yum::Versionlock['kernel-devel'],
      }
    }

    if $debuginfo {
      yum::versionlock { 'kernel-debuginfo':
        ensure  => present,
        version => $version,
      }

      # reboot is not needed for -debuginfo
      package { 'kernel-debuginfo':
        ensure          => present,
        name            => "kernel-debuginfo-${version}",
        install_options => ['--enablerepo', 'base-debuginfo'],
        require         => Yum::Versionlock['kernel-debuginfo'],
      }
    }

    # reboot if changing the kernel version
    package { 'kernel':
      ensure => present,
      name   => "kernel-${version}",
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
}

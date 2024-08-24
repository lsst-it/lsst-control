# @summary
#   Set a kernel parameter and reboot system to apply it
#
# @param name
#   Kernel parameter string. E.g.: `systemd.unified_cgroup_hierarchy=0`
#
# @param reboot
#   Whether or not to force a reboot to ensure kernel parameter is set on the running kernel.
#   Defaults to `true`.
#
# @param ensure
#   Whether the kernel parameter should be present or absent.
#   Defaults to `preset`.
#
define profile::util::kernel_param (
  Boolean $reboot = true,
  Enum['present', 'absent'] $ensure = 'present',
) {
  $message = "set kernel parameter: ${name} to ${ensure}"

  grubby::kernel_opt { $name:
    ensure => $ensure,
    scope  => 'ALL',
  }

  if ($reboot) {
    reboot { $name:
      apply     => finished,
      message   => $message,
      when      => refreshed,
      subscribe => Grubby::Kernel_opt[$name],
    }
  }
}

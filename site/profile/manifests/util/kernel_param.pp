# @summary
#   Set a kernel parameter and reboot system to apply it
#
# @param name
#   Kernel parameter string. E.g.: `systemd.unified_cgroup_hierarchy=0`
#
define profile::util::kernel_param {
  $message = "set kernel parameter: ${name}"

  kernel_parameter { $name:
    ensure => present,
  }
  ~> reboot { $name:
    apply   => finished,
    message => $message,
    when    => refreshed,
  }
}

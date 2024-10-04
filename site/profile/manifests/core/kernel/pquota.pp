# @summary
#   Enable pquota on the root filesystem. Only applicable when the root
#   filesystm is XFS.
#
# @param ensure
#   Whether the kernel parameter should be present or absent.
#
class profile::core::kernel::pquota (
  Enum['present', 'absent'] $ensure = 'present',
) {
  profile::util::kernel_param { 'rootflags=pquota':
    ensure => $ensure,
    reboot => false,
  }
}

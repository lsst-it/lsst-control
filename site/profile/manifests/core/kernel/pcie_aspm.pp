# @summary
#   Disable PCIe ASPM.
#
#   See: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/power_management_guide/aspm
#
class profile::core::kernel::pcie_aspm {
  profile::util::kernel_param { 'pcie_aspm=off': }
}

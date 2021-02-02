# @summary
#   Common functionality needed by kubernetes nodes.
#
# @param enable_dhcp
#   Enable CNI dhcp plugin
#
class profile::core::k8s(
  Boolean $enable_dhcp = false,
) {
  if $enable_dhcp {
    include cni::plugins
    include cni::plugins::dhcp
  }
}

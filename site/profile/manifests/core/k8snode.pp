# @summary
#   Common functionality needed by kubernetes nodes.
#
# @param enable_dhcp
#   Enable CNI dhcp plugin
#
class profile::core::k8snode (
  Variant[Boolean, Enum['service_only']] $enable_dhcp = false,
) {
  $pkgs = [
    'gdisk',  # used to cleanup after rook-ceph
  ]
  ensure_packages($pkgs)

  if $enable_dhcp {
    if $enable_dhcp == 'service_only' {
      include cni
      include cni::plugins::dhcp::service
    } else {
      include cni::plugins
      include cni::plugins::dhcp
    }
  }

  sysctl::value { 'fs.inotify.max_user_instances':
    value  => 104857,
    target => '/etc/sysctl.d/80-rke.conf',
  }
  sysctl::value { 'fs.inotify.max_user_watches':
    value  => 1048576,
    target => '/etc/sysctl.d/80-rke.conf',
  }
}

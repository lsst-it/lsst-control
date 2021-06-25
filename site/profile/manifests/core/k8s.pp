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

  $user = 'rke'

  vcsrepo { "/home/${user}/k8s-cookbook":
    ensure             => present,
    provider           => git,
    source             => 'https://github.com/lsst-it/k8s-cookbook.git',
    keep_local_changes => true,
    user               => $user,
    owner              => $user,
    group              => $user,
  }
}

# @summary
#   Manage iptables
#
# @param firewall
#   `firewall` resources to create.
#
# @param purge_firewall
#   If `true`, purge all unmanaged `firewall` resources.
#
class profile::core::firewall (
  Optional[Hash[String, Hash]] $firewall = undef,
  Boolean $purge_firewall = false,
) {
  include firewall
  include ipset

  if $purge_firewall {
    resources { 'firewall': purge => true }
  }

  if $firewall {
    ensure_resources('firewall', $firewall)
  }
}

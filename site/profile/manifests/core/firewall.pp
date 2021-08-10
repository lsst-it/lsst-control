class profile::core::firewall (
  Optional[Hash[String, Hash]] $firewall = undef,
  Boolean $purge_firewall = false,
) {
  include firewall

  if $purge_firewall {
    resources { 'firewall': purge => true }
  }

  if $firewall {
    ensure_resources('firewall', $firewall)
  }
}

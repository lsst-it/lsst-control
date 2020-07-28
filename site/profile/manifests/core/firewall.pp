class profile::core::firewall(
  Optional[Hash[String, Hash]] $firewall = undef
) {
  include firewall

  if ($firewall) {
    ensure_resources('firewall', $firewall)
  }
}

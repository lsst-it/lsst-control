# @summary
#   Manage ipset resources.
#
# @param set
#   `ipset::set` resources to create.
#
class profile::core::ipset (
  Optional[Hash[String, Hash]] $set = undef,
) {
  if $set {
    ensure_resources('ipset::set', $set)
  }
}

# @summary
#   This empty class exists solely as a vehicle for shipping enc data to puppetdb.
#
#   Note that the facts hash does not contain enc parameters and they must be
#   accessed as top scoped variables.
#
# @param site
# @param role
# @param cluster
# @param variant
# @param subvariant
#
# lint:ignore:top_scope_facts
class profile::core::node_info (
  Optional[String] $site = $::site,
  Optional[String] $role = $::role,
  Optional[String] $cluster = $::cluster,
  Optional[String] $variant = $::variant,
  Optional[String] $subvariant = $::subvariant,
) {
# lint:endignore
}

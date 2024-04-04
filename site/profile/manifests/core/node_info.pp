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
  Optional[String[1]] $site = $::site,
  Optional[String[1]] $role = $::role,
  Optional[String[1]] $cluster = $::cluster,
  Optional[String[1]] $variant = $::variant,
  Optional[String[1]] $subvariant = $::subvariant,
) {
# lint:endignore
}

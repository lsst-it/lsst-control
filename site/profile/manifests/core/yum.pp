# @summary
#   Manage yum repos and package versions
#
# @param versionlock
#   Hash of yum::versionlock resources to create
#
class profile::core::yum(
  Optional[Hash[String, Hash]] $versionlock = undef,
) {
  include yum
  include yum::plugin::versionlock

  if $versionlock {
    ensure_resources('yum::versionlock', $versionlock)
  }
}

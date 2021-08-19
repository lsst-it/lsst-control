# @summary
#   Configure CCS related sysctl(s) to tune for DAQ connection.
#
# @param sysctls
#   Hash of sysctl::value resources to create
#
class profile::ccs::sysctl (
  Optional[Hash[String, Hash]] $sysctls = undef,
) {
  if $sysctls {
    ensure_resources('sysctl::value', $sysctls)
  }
}

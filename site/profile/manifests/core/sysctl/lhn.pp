# @summary
#   Configure network related sysctl(s) to tune data transfer over the LHN.
#
# @param sysctls
#   Hash of sysctl::value resources to create
#
class profile::core::sysctl::lhn (
  Optional[Hash[String, Hash]] $sysctls = undef,
) {
  if $sysctls {
    ensure_resources('sysctl::value', $sysctls)
  }
}

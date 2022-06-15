# @summary
#   Configure CCS related sysctl(s) to tune for DAQ connection.
#
# @param sysctls
#   Hash of sysctl::value resources to create
#
class profile::daq::sysctl (
  Optional[Hash[String, Hash]] $sysctls = undef,
) {
  if $sysctls {
    ensure_resources('sysctl::value', $sysctls)
  }

  # cleanup after 99-lsst-daq-ccs.conf -> 99-lsst-daq.conf rename
  file { '/etc/sysctl.d/99-lsst-daq-ccs.conf':
    ensure => absent,
  }
}

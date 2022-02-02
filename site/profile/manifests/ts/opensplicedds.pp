# @summary
#   Manages OpenSpliceDDS package
#
# @param ensure
#   Ensure parameter for openslice package resource.
#
class profile::ts::opensplicedds (
  String $ensure = 'present',
) {
  require profile::core::yum::lsst_ts_private

  package { 'OpenSpliceDDS':
    ensure => $ensure,
  }
}

# @summary
#   Manages OpenSpliceDDS package
#
class profile::ts::opensplicedds (
  String $ensure = 'present',
) {
  require profile::core::yum::lsst_ts_private

  package { 'OpenSpliceDDS':
    ensure => $ensure,
  }
}

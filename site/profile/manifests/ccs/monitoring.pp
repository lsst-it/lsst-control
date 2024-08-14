# @summary
#   Monitoring for CCS hosts.
#
# @param mrtg
#   Boolean - if true, install mrtg.
#
class profile::ccs::monitoring (
  Boolean $mrtg = false,
) {
  ## These will be replaced by some other alerting/monitoring system.
  include ccs_monit

  if ($mrtg) {
    include ccs_mrtg
  }
}

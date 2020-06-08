#
# @summary
#   Common functionality needed by ccs nodes.
#
class profile::ccs::common {
  include ccs_software
  include java_artisanal

  Class['java_artisanal']
  -> Class['ccs_software']
}

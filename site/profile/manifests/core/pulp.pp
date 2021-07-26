# @summary
#   Configure and install a Pulp server or node.
#
class profile::core::pulp() {
  include epel
  include pulp
  include pulp::repo::upstream

  Class['epel'] -> Class['pulp']
  Class['pulp::repo::upstream'] -> Class['pulp']
}

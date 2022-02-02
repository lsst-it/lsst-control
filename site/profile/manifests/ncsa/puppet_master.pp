# @summary
#   Configure host settings on a puppet master
#
# @param firewall_allow_from
#   List of source IPs to allow access from
class profile::ncsa::puppet_master (
  Array[String, 1] $firewall_allow_from,
) {
  # allow incoming on port 8140
  $firewall_allow_from.each | String $cidr | {
    firewall { "500 profile::ncsa::puppet_master - puppet access from '${cidr}'" :
      proto  => 'tcp',
      dport  => '8140',
      action => 'accept',
      source => $cidr,
    }
  }
}

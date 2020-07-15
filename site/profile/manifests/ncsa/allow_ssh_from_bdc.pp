# @summary Allow incoming ssh from BDC nodes
#
# Allow incoming ssh from BDC nodes
#
# @param
#   nodelist
#   Type: Array
#   Desc: one or more hostnames / IPs / CIDRs
#         Note: must contain at least 1 item
# @param
#   allow_groups
#   Type: Array
#   Desc: one or more LDAP / UNIX groups that are allowed to login from
#         any of the nodes in nodelist
#         Note: can be empty
# @example
#   include profile::allow_ssh_from_BDC
#
class profile::ncsa::allow_ssh_from_bdc (
  Array[ String ]    $allow_groups,
  Array[ String, 1 ] $nodelist,
  Hash               $custom_cfg,
) {
  $parms_local = {
    'PubkeyAuthentication'   => 'yes',
    'KerberosAuthentication' => 'yes',
    'GSSAPIAuthentication'   => 'yes',
  }

  #add in allow_groups if non-empty
  if size( $allow_groups ) > 0 {
    $groups = { 'AllowGroups' => $allow_groups }
  }
  else {
    $groups = {}
  }

  $params = $parms_local + $groups + $custom_cfg

  ::sshd::allow_from{ 'allow ssh from BDC nodes':
    hostlist                => $nodelist,
    groups                  => $allow_groups,
    additional_match_params => $params,
  }
}

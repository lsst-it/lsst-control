# Allow incoming ssh from any bastion nodes
#
# @summary Allow incoming ssh from any bastion nodes
#
# @param
#   bastion_nodelist
#   Type: Array
#   Desc: one or more hostnames / IPs / CIDRs
#         Note: must contain at least 1 item
# @param
#   allow_groups
#   Type: Array
#   Desc: one or more LDAP / UNIX groups that are allowed to login from
#         any of the nodes in bastion_nodelist
#         Note: can be empty
# @example
#   include profile::allow_ssh_from_bastion
#
class profile::ncsa::allow_ssh_from_bastion (
  Array[ String ]    $allow_groups,
  Array[ String, 1 ] $bastion_nodelist,
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
  #join the param hashs
  $params = $parms_local + $groups + $custom_cfg

  ::sshd::allow_from{ 'sshd allow from bastion nodes':
    hostlist                => $bastion_nodelist,
    groups                  => $allow_groups,
    additional_match_params => $params,
  }
}

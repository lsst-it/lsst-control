# @summary Allow sudo access for users and/or groups
#          Configures sudoers and access.conf
#
# @param users
#   Type: Array
#   Desc: one or more LDAP / UNIX users that are allowed sudo access
#   Note: can be empty
#
# @param groups
#   Type: Array
#   Desc: one or more LDAP / UNIX groups that are allowed to login from
#   Note: can be empty
#
# @example
#   include profile::ncsa::allow_sudo
#
class profile::ncsa::allow_sudo (
  Array[String] $users  = [],
  Array[String] $groups = [],
) {
  # Validate Input
  if empty( $users ) and empty( $groups ) {
    fail( "'users' and 'groups' cannot both be empty" )
  }

  # GROUPS
  $groups.each |String $group| {
    sudo::conf { "sudo for group ${group}":
      content  => "%${group} ALL=(ALL) NOPASSWD: ALL",
    }

    pam_access::entry { "Allow sudo for group ${group}":
      group      => $group,
      origin     => 'LOCAL',
      permission => '+',
      position   => '-1',
    }
  }

  # USERS
  $users.each |String $user| {
    sudo::conf { "sudo for user ${user}":
      content => "%${user} ALL=(ALL) NOPASSWD: ALL",
    }

    pam_access::entry { "Allow sudo for user ${user}":
      user       => $user,
      origin     => 'LOCAL',
      permission => '+',
      position   => '-1',
    }
  }
}

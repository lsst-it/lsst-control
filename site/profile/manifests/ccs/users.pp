class profile::ccs::users {

  $users = lookup("${title}::users", Hash, 'hash')
  $groups = lookup("${title}::groups", Hash, 'hash')

  $groups.each | String $groupname, Hash $attrs | {
    group { $groupname:
      * => $attrs,
    }
  }

  $users.each | String $username, Hash $attrs | {
    user { $username:
      * => $attrs,
    }
  }

}

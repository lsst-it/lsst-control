class profile::ccs::users ( Hash $users, Hash $groups ) {

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

# @summary
#   Setups repo LOVE integrations tool
#
class profile::ts::love {
  $user = 'dco'
  vcsrepo { "/home/${user}/love-integration-tools":
    ensure             => present,
    provider           => git,
    source             => 'https://github.com/lsst-ts/LOVE-integration-tools.git',
    keep_local_changes => true,
    user               => $user,
    owner              => $user,
    group              => $user,
  }
}

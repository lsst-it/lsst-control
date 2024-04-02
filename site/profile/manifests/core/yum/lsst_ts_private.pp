# @summary
#   Manage lsst-ts-private/ts_yum_private repo
#
# @param repos
#   Hash of yum::versionlock resources to create
#
# @param username
#   yumrepo basic auth username
#
# @param password
#   yumrepo basic auth password
#
class profile::core::yum::lsst_ts_private (
  Optional[Hash] $repos      = undef,
  Optional[String[1]] $username = undef,
  Optional[Sensitive[String[1]]] $password = undef,
) {
  if $repos {
    $_real_repos = $repos.map |String $k, Hash $h| {
      [$k, $h + { username => $username, password => $password }]
    }
    create_resources('yumrepo', Hash($_real_repos))
  }
}

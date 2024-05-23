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
  Optional[Variant[Sensitive[String[1]],String[1]]] $username = undef,
  Optional[Sensitive[String[1]]] $password = undef,
) {
  if $repos {
    $_real_repos = $repos.map |String $k, Hash $h| {
      # yumrepo supports password as Sensitive but not username
      [$k, $h + { username => $username.unwrap, password => $password }]
    }
    create_resources('yumrepo', Hash($_real_repos))
  }
}

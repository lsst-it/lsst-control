# @summary
#   Manage lsst-ts/ts_yum repo
#
# @param repos
#   Hash of yum::versionlock resources to create
#
class profile::core::yum::lsst_ts (
  Optional[Hash] $repos = undef,
) {
  if $repos {
    create_resources('yumrepo', $repos)
  }
}

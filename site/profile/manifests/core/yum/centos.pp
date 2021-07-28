# @summary
#   Manage centos default yum repos
#
# @param repos
#   Hash of yum::versionlock resources to create
#
class profile::core::yum::centos(
  Optional[Hash] $repos = undef,
) {
  if $repos {
    create_resources('yumrepo', $repos)
  }
}

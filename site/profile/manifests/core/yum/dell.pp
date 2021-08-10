# @summary
#   Manage dell yumrepo
#
# @param repos
#   Parameters of yumrepo resoursce
#
class profile::core::yum::dell (
  Optional[Hash] $repo = undef,
) {
  if $repo {
    create_resources('yumrepo', { 'dell' => $repo })
  }
}

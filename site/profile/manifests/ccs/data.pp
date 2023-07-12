# @summary
#   Generic ccs /data path hierarchy
#
# @param files
#   `file` resources to create.
#
class profile::ccs::data (
  Optional[Hash[String, Hash]] $files = undef,
) {
  if $files {
    ensure_resources('file', $files)
  }
}

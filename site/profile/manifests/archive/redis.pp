# @summary
#   Simple redis wrapper class for archiver
#
class profile::archive::redis (
  Optional[Hash[String, Hash]] $files = undef,
) {
  if $files {
    ensure_resources('file', $files)
  }

  include ::redis
}

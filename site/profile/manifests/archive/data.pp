# @summary
#   Generic archiver /data path hierarchy
#
class profile::archive::data (
  Optional[Hash[String, Hash]] $files = undef,
) {
  if $files {
    ensure_resources('file', $files)
  }
}

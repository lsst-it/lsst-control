# @summary
#   comcam-archiver /data path hierarchy
#
# @param files
#   `file` resources to create.
#
class profile::archive::data::comcam (
  Optional[Hash[String, Hash]] $files = undef,
) {
  if $files {
    ensure_resources('file', $files)
  }
}

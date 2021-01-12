# @summary
#   Generates k5login resoures
#
# @param k5login
#   Hash of k5login resources to create
#
class profile::core::k5login (
  Optional[Hash[String, Hash]] $k5login = undef,
) {
  if $k5login {
    ensure_resources('k5login', $k5login)
  }
}

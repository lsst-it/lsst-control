# @param password
#   Default encryption password for the Restic repository
#
class profile::core::restic (
  Optional[Variant[Sensitive[String],String]] $password = "foo",
) {
  include restic
}

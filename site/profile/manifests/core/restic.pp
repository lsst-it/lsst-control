# @param password
#   Default encryption password for the Restic repository
#
class profile::core::restic (
  Optional[Variant[Sensitive[String],String]] $password = undef,
) {
  include restic
}

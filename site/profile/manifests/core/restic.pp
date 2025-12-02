# @summary
#   Provides an easy way to turn restic backups on or off for a host.
#
# @param enable
#   Whether to enable restic backups on this host.
#
class profile::core::restic (
  Boolean $enable = false,
) {
  if $enable {
    include restic
  }
}

# @summary
#   Simple redis wrapper class for archiver
#
# @param files
#   `file` resources to create.
#
class profile::archive::redis (
  Optional[Hash[String, Hash]] $files = undef,
) {
  if $files {
    ensure_resources('file', $files)
  }

  class { 'redis::globals':
    scl => 'rh-redis5',
  }
  -> class { 'redis':
    bind           => '0.0.0.0',
    manage_repo    => true,
    package_ensure => '5.0.5-1.el7.x86_64',
  }
}

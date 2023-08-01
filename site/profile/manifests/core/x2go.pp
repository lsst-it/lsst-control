# @summary
#   Adds additional packages for x2go agent
#
# @param packages
#  An array of packages to install
#
class profile::core::x2go (
  Optional[Array[String[1]]] $packages = undef,
) {
  if $packages {
    ensure_packages($packages)
  }

  # the rpm set mode for this file is 644, which upsets the visudo command
  file { '/etc/sudoers.d/x2goserver':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    require => Package['x2goserver'],
  } -> Sudo::Conf <||>
}

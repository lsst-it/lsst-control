# @summary
#   Adds additional packages for x2go agent
class profile::core::x2go {
  ensure_packages([
      'x2goagent',
      'x2goclient',
      'x2godesktopsharing',
      'x2goserver',
      'x2goserver-common',
      'x2goserver-xsession',
  ])

  # the rpm set mode for this file is 644, which upsets the visudo command
  file { '/etc/sudoers.d/x2goserver':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    require => Package['x2goserver'],
  } -> Sudo::Conf <||>
}

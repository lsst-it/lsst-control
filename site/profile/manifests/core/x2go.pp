# @summary
#   Adds additional packages for x2go agent
class profile::core::x2go {
  ensure_packages([
      'x2goserver',
      'x2goclient',
      'x2goserver-common',
      'x2goserver-xsession',
      'x2goagent',
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

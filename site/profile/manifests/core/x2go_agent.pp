# @summary
#   Adds additional packages for x2go agent

class profile::core::x2go_agent {

  $packages = [
    'x2goserver',
    'x2goclient',
    'x2goserver-common',
    'x2goserver-xsession',
    'x2goagent',
  ]

  package { $packages:
    ensure => 'present',
  }
  yum::group { 'Mate':
    ensure => present,
  }
}

# x2go
#
#
class x2go {
  # install the x2go package
  package {'x2goserver':
    ensure => present,
  }
  # install the x2go package
  package {'x2goserver-xsession':
    ensure => present,
  }
}


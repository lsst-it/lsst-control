# x2go
#
#

class x2go {
#  notify { "x2go-header":
#    message => "This is the x2go module"
#  }

  include mate
  include epel

  # install the x2go package
  package {"x2goserver":
    ensure => present,
  }
  # install the x2go package
  package {"x2goserver-xsession":
    ensure => present,
  }
  # configure x2go config file
  # file { "/etc/x2go/not-a-real-file":
  #   ensure  => present,
  #   content => "hello!"
  # }
  # start the x2go service

  # manage the x2goserver sudo rule
}

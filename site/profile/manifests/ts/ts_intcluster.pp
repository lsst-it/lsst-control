# Class used to install virtualbox in server to be used as hypervisors for deployments tests
class profile::ts::ts_intcluster {
  include profile::it::ssh_server
  $kernel_devel = lookup('kernel_devel')
  class {'virtualbox':
    require      => Package[$kernel_devel],
    package_name => lookup('virtualbox_version'),
  }

  package{'vagrant':
    ensure   => installed,
    source   => lookup('vagrant_rpm'),
    provider => rpm
  }

  package{$kernel_devel:
    ensure => installed
  }
  package{'xauth':
    ensure => installed
  }

}

# Class responsible for the LSST Users creation
class profile::it::lsst_users {
  # group/user creation

  # as per /etc/login.defs, max uid is 999, so we have set 777 as the default group admin account
  group { 'sysadmin':
    ensure          => present,
    gid             => 777,
    auth_membership => true,
    members         => ['sysadmin']
  }

  #current user for sudo access is wheel, in centos 7 it has GID=10
  group { 'wheel':
    ensure          => present,
    gid             => 10,
    auth_membership => true,
    members         => ['sysadmin'],
    require         => Group['sysadmin'],
  }

  # as per /etc/login.defs, max uid is 999, so we have set 777 as the default group admin account
  user{ 'sysadmin':
    ensure     => 'present',
    uid        => '777' ,
    gid        => '777',
    home       => '/home/sysadmin',
    managehome => true,
    password   => lookup('lsst_sysadmin_pwd')
  }

  file{ '/home/sysadmin':
    ensure  => directory,
    mode    => '0700',
    require => User['sysadmin'],
  }

  user{'root':
    password => lookup('root_pwd'),
  }

  group { 'lsst':
    ensure          => present,
    gid             => 500,
    auth_membership => true,
    members         => ['sysadmin'],
  }

}

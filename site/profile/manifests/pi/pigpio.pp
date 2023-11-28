# @summary
#  This class installs the pigpio package

class profile::pi::pigpio {
  yumrepo { 'raspberry-pi':
    descr               => 'Copr repo for raspberry-pi owned by pemensik',
    baseurl             => 'https://download.copr.fedorainfracloud.org/results/pemensik/raspberry-pi/fedora-37-$basearch/',
    skip_if_unavailable => 'true',
    gpgcheck            => '1',
    gpgkey              => 'https://download.copr.fedorainfracloud.org/results/pemensik/raspberry-pi/pubkey.gpg',
    enabled             => '1',
    target              => '/etc/yum.repo.d/raspberry-pi.repo',
  }
  -> package { 'pigpio':
    ensure => 'installed',
  }

  file { '/etc/sysconfig/pigpiod':
    ensure  => 'file',
    mode    => '0644',
    # lint:ignore:strict_indent
    content => @(CONTENT),
      # Command line options for pigpiod
      OPTIONS="-l -n localhost"
      | CONTENT
    # lint:endignore
  }

  $service_unit = @(UNIT)
    [Unit]
    Description=A utility to start the pigpio library as a daemon.
    Requires=network-online.target
    After=network.target

    [Service]
    EnvironmentFile=/etc/sysconfig/pigpiod
    Type=forking
    ExecStart=/bin/pigpiod $OPTIONS

    [Install]
    WantedBy=multi-user.target
    | UNIT

  systemd::unit_file { 'pigpiod.service':
    content => $service_unit,
  }
  ~> service { 'pigpiod':
    ensure    => 'running',
    enable    => true,
    subscribe => [
      File['/etc/sysconfig/pigpiod'],
      Package['pigpio'],
    ],
  }
}

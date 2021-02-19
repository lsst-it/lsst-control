#
# @summary
#   Provides base packages for SAL/DDS diagnostics
#

class profile::ccs::sal_dx (
  String $username,
  String $password,
){
  $directory = '/opt/lsst-ts'
  $packages = [
    'vim',
    'ltrace',
    'strace',
    'tcpdump',
    'traceroute',
    'gdb',
    'htop',
    'iftop',
    'wireshark',
    'nethogs',
    'etherape',
    'iptraf-ng',
  ]

  yumrepo { 'ts_yum_private':
    ensure   => 'present',
    enabled  => true,
    gpgcheck => false,
    descr    => 'LSST Telescope and Site Private Packages',
    baseurl  => "https://${username}:${password}@repo-nexus.lsst.org/nexus/repository/ts_yum_private",
    target   => '/etc/yum.repos.d/ts_yum_private.repo',
  }
  ->package {'OpenSpliceDDS-6.10.4-6':
    ensure => present,
  }

  yum::group { 'Development Tools':
    ensure => present,
  }
  ->package { $packages:
    ensure => present,
  }

  file { $directory:
    ensure => 'directory'
  }
  vcsrepo { "${directory}/ts_sal":
    ensure   => present,
    provider => git,
    source   => 'https://github.com/lsst-ts/ts_sal',
  }
  vcsrepo { "${directory}/ts_xml":
    ensure   => present,
    provider => git,
    source   => 'https://github.com/lsst-ts/ts_xml',
  }
  vcsrepo { "${directory}/ts_salobj":
    ensure   => present,
    provider => git,
    source   => 'https://github.com/lsst-ts/ts_salobj',
  }
  vcsrepo { "${directory}/ts_idl":
    ensure   => present,
    provider => git,
    source   => 'https://github.com/lsst-ts/ts_idl',
  }
  vcsrepo { "${directory}/ts_config_ocs":
    ensure   => present,
    provider => git,
    source   => 'https://github.com/lsst-ts/ts_config_ocs',
  }
}

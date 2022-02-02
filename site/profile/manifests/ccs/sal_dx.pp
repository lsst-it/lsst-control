#
# @summary
#   Provides base packages for SAL/DDS diagnostics
#
class profile::ccs::sal_dx {
  require profile::ts::opensplicedds

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

  yum::group { 'Development Tools':
    ensure => present,
  }
  ->package { $packages:
    ensure => present,
  }

  file { $directory:
    ensure => 'directory',
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

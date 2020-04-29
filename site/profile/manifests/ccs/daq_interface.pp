# XXX it might be better to simply set a per host network interface setup
# instead of resorting to conditional logic in a profile.  The main reason to
# centralize it is to make it easier to change the rx/tx/etc. settings on all
# hosts with a DAQ interface.
class profile::ccs::daq_interface(
  String $hwaddr,
  String $uuid,
  String $was,
  Enum['dhcp-client', 'dhcp-server'] $mode,
) {

  $netconf = $mode ? {
    'dhcp-client'  => {
      bootproto => 'dhcp',
    },
    'dhcp-server'  => {
      bootproto => 'none',
      ipaddress => '192.168.100.1',
      netmask   => '255.255.255.0',
    },
  }

  network::interface { 'lsst-daq':
    defroute     => 'no',  # this was yes on comcam-fp01
    ethtool_opts => '--set-ring ${DEVICE} rx 4096 tx 4096; --pause ${DEVICE} autoneg off rx on tx on',
    hwaddr       => $hwaddr,
    ipv6init     => 'no',
    onboot       => true,
    type         => 'Ethernet',
    uuid         => $uuid,
    *            => $netconf,
  }

  network::interface { $was:
    ensure => absent,
  }

  # restarting the network service isn't sufficent to rename an existing
  # interface.  The host has to be rebooted.
  $daq_int = $facts['networking']['interfaces']['lsst-daq']

  unless ($daq_int) {
    notify { 'lsst-daq network interface is missing':
      notify => Reboot['lsst-daq'],
    }
  }

  Class['network']
  ~> reboot { 'lsst-daq':
    apply   => finished,
    message => 'setup lsst-daq network interface',
    when    => refreshed,
  }
}

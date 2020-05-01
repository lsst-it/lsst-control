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
  $interface = 'lsst-daq'

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

  network::interface { $interface:
    defroute => 'no',  # this was yes on comcam-fp01
    hwaddr   => $hwaddr,
    ipv6init => 'no',
    onboot   => true,
    type     => 'Ethernet',
    uuid     => $uuid,
    *        => $netconf,
  }

  network::interface { $was:
    ensure => absent,
  }

  # restarting the network service isn't sufficent to rename an existing
  # interface.  The host has to be rebooted.
  unless ($facts['networking']['interfaces'][$interface]) {
    notify { "${interface} network interface is missing":
      notify => Reboot['lsst-daq'],
    }
  }

  Class['network']
  -> reboot { $interface:
    apply   => finished,
    message => "setup ${interface} network interface",
    when    => refreshed,
  }

  # NM apears to ignore ETHTOOL_OPTS and requires a dispatch script to be used
  # to set device parameters
  $ptitle = regsubst($title, '::', '/', 'G')
  $file = '30-ethtool'

  # XXX we need to have a discussion as to wether or not it is appropriate for
  # a template to live in a profile.
  file { "/etc/NetworkManager/dispatcher.d/${file}":
    ensure  => file,
    content => epp("${ptitle}/${file}", {'interface' => $interface}),
    mode    => '0755',
  }
}

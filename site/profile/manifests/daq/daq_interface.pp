# @summary
#   Configure a DAQ network interface named `lsst-daq`.
#
# @param hwaddr
#   MAC address of DAQ network interface
#
# @param uuid
#   NetworkManager UUID of DAQ network interface
#
# @param was
#   Name of the interface *before* it has been renamed to `lsst-daq`.
#
# @param mode
#   Is this a `dhcp-client` or `dhcp-server` node.  Only one host per DAQ network may be a
#   `dhcp-server.
#
# XXX it might be better to simply set a per host network interface setup
# instead of resorting to conditional logic in a profile.  The main reason to
# centralize it is to make it easier to change the rx/tx/etc. settings on all
# hosts with a DAQ interface.
class profile::daq::daq_interface (
  Optional[String] $hwaddr                           = undef,
  Optional[String] $uuid                             = undef,
  Optional[String] $was                              = undef,
  Optional[Enum['dhcp-client', 'dhcp-server']] $mode = undef,
) {
  if $mode {
    unless $hwaddr { fail('hwaddr param is required when mode is set') }
    unless $uuid { fail('uuid param is required when mode is set') }
    unless $was { fail('was param is required when mode is set') }

    $interface = 'lsst-daq'

    unless fact('os.release.major') == '7' {
      fail('unsupported on EL8+')
    }

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

    Class['network'] -> Reboot[$interface]

    # restarting the network service isn't sufficient to rename an existing
    # interface.  The host has to be rebooted.
    unless ($facts['networking']['interfaces'][$interface]) {
      notify { "${interface} network interface is missing":
        notify => Reboot['lsst-daq'],
      }
    }

    reboot { $interface:
      apply   => finished,
      message => "setup ${interface} network interface",
      when    => refreshed,
    }

    # NM apears to ignore ETHTOOL_OPTS and requires a dispatch script to be used
    # to set device parameters
    $file = '30-ethtool'

    # XXX merge with profile::core::nm_dispatch
    file { "/etc/NetworkManager/dispatcher.d/${file}":
      ensure  => file,
      content => epp("${module_name}/ccs/daq_interface/${file}.epp", { 'interface' => $interface }),
      mode    => '0755',
    }
  }
}

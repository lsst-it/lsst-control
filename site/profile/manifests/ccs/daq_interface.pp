class profile::ccs::daq_interface(
  String $hwaddr,
  String $uuid,
) {
  network::interface { 'lsst-daq':
    type         => 'Ethernet',
    bootproto    => 'none',
    defroute     => 'no',  # this was yes on comcam-fp01
    hwaddr       => $hwaddr,
    ipv6init     => 'no',
    uuid         => $uuid,
    onboot       => true,
    ipaddress    => '192.168.100.1',
    netmask      => '255.255.255.0',
    ethtool_opts => '--set-ring ${DEVICE} rx 4096 tx 4096; --pause ${DEVICE} autoneg off rx on tx on'
  }
}

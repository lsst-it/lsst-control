class profile::core::manke_bridge {
  $ips     = lookup('profile::core::manke_bridge::ips', Hash, 'first', {})
  $address = $ips[$facts['networking']['hostname']]
  unless $address =~ Undef {
    nm::connection { 'br2501':
      content => {
        'connection' => {
          'id'             => 'br2501',
          'uuid'           => '8d5c6641-c8ee-41a3-830c-d81d0a7f3a90',
          'type'           => 'bridge',
          'interface-name' => 'br2501',
        },
        'ethernet'   => {},
        'bridge'     => { 'stp' => 'false' },
        'ipv4'       => {
          'method'     => 'manual',
          'address1'   => "${address},139.229.151.254",
          'dns'        => '139.229.134.53;139.229.134.54;139.229.134.55;',
          'dns-search' => 'ls.lsst.org;',
        },
        'ipv6'       => { 'method' => 'disabled' },
        'proxy'      => {},
      },
    }
  }
}

class profile::core::lonko_bridge {
  $ips     = lookup('profile::core::lonko_bridge::ips', Hash, 'first', {})
  $address = $ips[$facts['networking']['hostname']]
  unless $address =~ Undef {
    nm::connection { 'br2143':
      content => {
        'connection' => {
          'id'             => 'br2143',
          'uuid'           => 'eb85bd0d-4c59-435a-a23a-84fed273cf3e',
          'type'           => 'bridge',
          'interface-name' => 'br2143',
        },
        'ethernet'   => {},
        'bridge'     => { 'stp' => 'false' },
        'ipv4'       => {
          'method'     => 'manual',
          'address1'   => "${address},139.229.143.190",
          'dns'        => '139.229.134.53;',
          'dns-search' => 'ls.lsst.org;',
        },
        'ipv6'       => { 'method' => 'disabled' },
        'proxy'      => {},
      },
    }
  }
}

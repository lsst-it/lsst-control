class profile::ncsa::lhn_target_from_bdc {

  $protocols = [ 'udp', 'tcp' ]
  $sources = [
    '139.229.140.0/22',
    '139.229.146.0/24',
    '139.229.149.0/24',
    '198.32.252.217/32',
  ]

  $protocols.each | $proto | {
    $sources.each | $src | {
      firewall { "550 profile::ncsa::allow_lhn_from_bdc - ${src} + ${proto}" :
        action => 'accept',
        dport  => '5000-5050',
        source => $src,
        proto  => $proto,
      }
    }
  }

}

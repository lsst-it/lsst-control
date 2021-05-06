# Docker and Docker-compose
#
# Firewallchain adjustments based on:
# https://gist.github.com/pmoranga/9c4f194a1ac4102d4f94
# and
# https://github.com/lsst-it/puppet-baseline_cfg/blob/c9fcdf072126c3f42a0322ffef9ddfad46a05e2/manifests/firewall.pp
class profile::docker {
  include ::docker
  include ::python

  ### ENSURE RULES CREATED BY DOCKER ARE NOT PURGED BY PUPPET

  # chain names created by docker
  $docker_names = [ 'DOCKER',
    'DOCKER-ISOLATION-STAGE-1',
    'DOCKER-ISOLATION-STAGE-2',
    'DOCKER-USER',
  ]


  # firewallchain names that will not be purged
  $filter_exempt_chains = $docker_names.map | $dname | {
    "${dname}:filter:IPv4"
  }
  $nat_exempt_chains = [ 'DOCKER:nat:IPv4' ]
  $purge_exempt_chains = $filter_exempt_chains + $nat_exempt_chains

  # Existing chains that will need purge exceptions
  $name_ignore_chains = [ 'INPUT:filter:IPv4',
    'OUTPUT:filter:IPv4',
    'FORWARD:filter:IPv4',
    'INPUT:nat:IPv4',
    'OUTPUT:nat:IPv4',
    'PREROUTING:nat:IPv4',
  ]
  $name_ignores = $docker_names + [ 'docker', '-o br-', '-i br-' ]

  $name_ip_ignore_chains = [ 'POSTROUTING:nat:IPv4' ]
  $name_ip_ignores = $docker_names + [ '172.17', '172.18', '172.19' ]


  firewallchain {
    $purge_exempt_chains :
      purge => false,
      ;
    $name_ignore_chains :
      ignore => $name_ignores,
      ;
    $name_ip_ignore_chains :
      ignore => $name_ip_ignores,
      ;
    default :
      purge => true,
      ;
  }

}

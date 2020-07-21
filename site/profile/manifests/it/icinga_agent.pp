# @summary
#   Icinga agent creation for metric collections

class profile::it::icinga_agent(
  String $icinga_satellite_ip = '139.229.135.28',
  String $icinga_satellite_fqdn = 'icinga-satellite.ls.lsst.org',
  String $salt = '5a3d695b8aef8f18452fc494593056a4',
  String $icinga_master_ip = '139.229.135.31'
)
{
  $icinga_agent_fqdn = $facts['fqdn']
  $icinga_agent_ip = $facts['ipaddress']

  class { '::icinga2':
    manage_repo => true,
    confd       => false,
    features    => ['mainlog'],
  }
  class { '::icinga2::feature::api':
    accept_config   => true,
    accept_commands => true,
    ca_host         => $icinga_satellite_ip,
    ticket_salt     => $salt,
    endpoints       => {
      'NodeName'             => {
        'host'  =>  $icinga_agent_ip
      },
      $icinga_satellite_fqdn => {
        'host'  =>  $icinga_satellite_ip,
      },
    },
    zones           => {
      'ZoneName'  => {
        'endpoints' => ['NodeName'],
        'parent'    => 'satellite',
      },
      'satellite' => {
        'endpoints' => [$icinga_satellite_fqdn],
      },
    }
  }
  class { '::icinga2::feature::notification':
    ensure    => present,
    enable_ha => true,
  }
  icinga2::object::zone { 'global-templates':
    global => true,
  }
}

# @summary
#   Icinga agent creation for metric collections

class profile::it::icinga_agent(
  String $sat_zone = 'BDC',
  String $icinga_satellite_ip = '139.229.135.28',
  String $icinga_satellite_fqdn = 'icinga-satellite.ls.lsst.org',
  String $salt = '5a3d695b8aef8f18452fc494593056a4',
  String $icinga_master_ip = '139.229.135.31',
  String $icinga_master_fqdn = 'icinga-master.ls.lsst.org',
)
{
  $icinga_agent_fqdn = $facts[fqdn]
  $icinga_agent_ip = $facts[ipaddress]

  class { '::icinga2':
    manage_repo => true,
    confd       => false,
    features    => ['mainlog'],
  }
  class { '::icinga2::feature::api':
    accept_config   => true,
    accept_commands => true,
    ca_host         => $icinga_master_ip,
    ticket_salt     => $salt,
    endpoints       => {
      $icinga_agent_fqdn     => {
        'host'  =>  $icinga_agent_ip
      },
      $icinga_master_fqdn    => {
        'host'  =>  $icinga_master_ip
      },
      $icinga_satellite_fqdn => {
        'host'  =>  $icinga_satellite_ip,
      },
    },
    zones           => {
      'master'           => {
        'endpoints'  => [$icinga_master_fqdn],
      },
      $sat_zone          => {
        'endpoints' => [$icinga_satellite_fqdn],
        'parent'    => 'master',
      },
      $icinga_agent_fqdn => {
        'endpoints' => [$icinga_agent_fqdn],
        'parent'    => $sat_zone,
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

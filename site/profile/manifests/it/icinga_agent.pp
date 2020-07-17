# @summary
#   Icinga agent creation for metric collections

class profile::it::icinga_agent(
  String $sat_zone = 'BDC',
  String $icinga_satellite_ip = '139.229.135.28',
  String $icinga_satellite_fqdn = 'icinga-satellite.ls.lsst.org',
)
{
  $icinga_hostname = $facts['fqdn']

  class { '::icinga2':
    manage_repo => true,
    confd       => false,
    constants   => {
      'NodeName' => $facts['fqdn'],
      'ZoneName' => "${sat_zone}",
    },
    features    => ['mainlog'],
  }
  class { '::icinga2::feature::api':
    ca_host       => '139.229.135.31',
    accept_config => true,
    endpoints     => {
        $icinga_hostname       => {},
        $icinga_satellite_fqdn => {
        'host'  =>  $icinga_satellite_ip,
      },
      },
      zones       => {
        'ZoneName'         => {
          'endpoints' => [$icinga_satellite_fqdn],
        },
        "${facts['fqdn']}" => {
          'endpoints' => ['NodeName'],
          'parent'    => 'ZoneName',
        },
      }
  }

  icinga2::object::zone { 'global-templates':
    global => true,
  }
}

# @summary
#   Icinga agent creation for metric collections

class profile::it::icinga_agent(
  String $salt = '5a3d695b8aef8f18452fc494593056a4',
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
      'NodeName'   => $facts['fqdn'],
      'ZoneName'   => "${sat_zone}",
      'TicketSalt' => $salt,
    },
    features    => ['mainlog'],
  }
  class { '::icinga2::feature::api':
    pki           => 'puppet',
    accept_config => true,
    ticket_salt   => 'TicketSalt',
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

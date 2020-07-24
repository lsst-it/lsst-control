# @summary
#   Same as common but excludes icinga agent

class profile::it::icinga_satellite (
  $icinga_master_fqdn,
  $icinga_master_ip,
  $salt,
  $api_user,
  $api_pwd,
){
  include profile::core::common
  include profile::core::remi

  $icinga_satellite_ip = $facts['ipaddress']
  $icinga_satellite_fqdn = $facts['fqdn']

  class { '::icinga2':
    manage_repo => true,
    confd       => false,
    features    => ['checker','mainlog'],
    constants   => {
      'ZoneName' => 'satellite',
    },
  }
  class { '::icinga2::feature::api':
    accept_config   => true,
    accept_commands => true,
    ca_host         => $icinga_master_ip,
    ticket_salt     => $salt,
    endpoints       => {
      $icinga_satellite_fqdn => {},
      $icinga_master_fqdn    => {
        'host'  =>  $icinga_master_ip,
      },
    },
    zones           => {
      'master'    => {
        'endpoints'  => [$icinga_master_fqdn],
      },
      'satellite' => {
        'endpoints' => [$icinga_satellite_fqdn],
        'parent'    => 'master',
      },
    },
  }
  class { '::icinga2::feature::notification':
    ensure    => present,
    enable_ha => true,
  }
  icinga2::object::zone { 'global-templates':
    global => true,
  }
  icinga2::object::zone { 'director-global':
    global => true,
  }
  icinga2::object::apiuser { $api_user:
    ensure      => present,
    password    => $api_pwd,
    permissions => [ 'status/query', 'actions/*', 'objects/modify/*', 'objects/query/*' ],
    target      => '/etc/icinga2/features-enabled/api-users.conf',
  }
}

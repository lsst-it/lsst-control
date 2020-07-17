# @summary
#   Same as common but excludes icinga agent

class profile::it::icinga_satellite (
  $icinga_master_fqdn,
  $icinga_master_ip,
  $sat_zone,
  $salt,
){
  include profile::core::uncommon
  include profile::core::remi

  class { '::icinga2':
    manage_repo => true,
    confd       => false,
    features    => ['checker','mainlog'],
    constants   => {
      'NodeName' => $facts[fqdn],
      'ZoneName' => $sat_zone,
    },
  }
  class { '::icinga2::feature::api':
    accept_config   => true,
    accept_commands => true,
    ca_host         => $icinga_master_ip,
    ticket_salt     => $salt,
    endpoints       => {
      'NodeName'          => {},
      $icinga_master_fqdn => {
        'host'  =>  $icinga_master_ip,
      },
    },
    zones           => {
      'master'   => {
        'endpoints'  => [$icinga_master_fqdn],
      },
      'ZoneName' => {
        'endpoints' => ['NodeName'],
        'parent'    => 'master',
      },
    },
  }
  icinga2::object::zone { 'global-templates':
    global => true,
  }
}

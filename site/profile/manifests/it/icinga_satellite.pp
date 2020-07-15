# @summary
#   Same as common but excludes icinga agent

class profile::it::icinga_satellite (
  $icinga_master_fqdn,
  $icinga_master_ip,
  $salt,
  $sat_zone,
){
  include profile::core::uncommon
  include profile::core::remi
  include ::icinga2::repo

  class { '::icinga2':
    confd     => false,
    features  => ['checker','mainlog'],
    constants => {
      'ZoneName'   => $sat_zone,
    },
  }
  class { '::icinga2::feature::api':
    pki             => 'puppet',
    accept_config   => true,
    accept_commands => true,
    ticket_salt     => $salt,
    endpoints       => {
      $facts['fqdn']      => {},
      $icinga_master_fqdn => {
        'host'  =>  $icinga_master_ip,
      },
    },
    zones           => {
      'master'   => {
        'endpoints'  => [$icinga_master_fqdn],
      },
      'ZoneName' => {
        'endpoints' => [$facts['fqdn']],
        'parent'    => 'master',
      },
    },
  }
  icinga2::object::zone { 'global-templates':
    global => true,
  }
}

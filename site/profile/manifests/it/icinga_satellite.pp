# @summary
#   Same as common but excludes icinga agent

class profile::it::icinga_satellite (
  $icinga_master_fqdn,
  $icinga_master_ip,
){
  include profile::core::uncommon
  include profile::core::remi
  include ::icinga2
  include ::icinga2::repo

  class { '::icinga2::feature::api':
    pki       => 'none',
    ca_host   => $icinga_master_ip,
    endpoints => {
      $icinga_master_fqdn => {},
      $facts['fqdn']      => {},
    },
    zones     => {
      'master'    => {
        'endpoints'  => [$icinga_master_fqdn],
      },
      'satellite' => {
        'endpoints' => [$facts['fqdn']],
        'parent'    => 'master',
      },
    },
  }
  icinga2::object::zone { 'global-templates':
    global => true,
  }
}

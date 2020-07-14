# @summary
#   Same as common but excludes icinga agent

class profile::it::icinga_satellite (
  $icinga_master,
){
  include profile::core::uncommon
  include profile::core::remi
  include ::icinga2
  include ::icinga2::repo

  class { '::icinga2::feature::api':
    pki             => 'none',
    accept_config   => true,
    accept_commands => true,
    endpoints       => {
      $icinga_master => {},
      $facts['fqdn'] => {},
    },
    zones           => {
      'master'    => {
        'endpoints'  => [$icinga_master],
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

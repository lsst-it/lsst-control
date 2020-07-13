# @summary
#   Icinga agent creation for metric collections

class profile::it::icinga_agent{

  include '::icinga2'

  $icinga_hostname = $facts['fqdn']

  class { '::icinga2::feature::api':
    accept_config => true,
    endpoints     => {
        $icinga_hostname => {},
      },
      zones       => {
        'Chile'  => {
          'endpoints' => [$icinga_hostname],
        },
      }
  }

  icinga2::object::zone { 'global-templates':
    global => true,
  }
}

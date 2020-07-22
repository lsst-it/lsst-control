# @summary
#   Icinga agent creation for metric collections

class profile::it::icinga_agent(
  String $salt = '5a3d695b8aef8f18452fc494593056a4',
  String $icinga_master_ip = '139.229.135.31',
  String $icinga_master_fqdn = 'icinga-master.ls.lsst.org',
  String $api_user = 'rubin',
  String $api_pwd = 'rubin-pwd',
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
    ca_host         => $icinga_master_ip,
    ticket_salt     => $salt,
    endpoints       => {
      $icinga_agent_fqdn  => {
        'host'  =>  $icinga_agent_ip
      },
      $icinga_master_fqdn => {
        'host'  =>  $icinga_master_ip,
      },
    },
    zones           => {
      $icinga_agent_fqdn => {
        'endpoints' => [$icinga_agent_fqdn],
        'parent'    => 'master',
      },
      'master'           => {
        'endpoints' => [$icinga_master_fqdn],
      },
    }
  }
  class { '::icinga2::feature::notification':
    ensure    => present,
    enable_ha => true,
  }
  class { '::icinga2::feature::checker':
    ensure    => present,
  }
  icinga2::object::zone { 'global-templates':
    global => true,
  }
  icinga2::object::zone { 'director-global':
    global => true,
  }
  icinga2::object::zone { 'basic-checks':
    global => true,
  }
  icinga2::object::apiuser { $api_user:
    ensure      => present,
    password    => $api_pwd,
    permissions => [ '*' ],
    target      => '/etc/icinga2/features-enabled/api-users.conf',
  }
  icinga2::object::host { $icinga_agent_fqdn:
    display_name  => $icinga_agent_fqdn,
    address       => $icinga_agent_ip,
    address6      => '::1',
    check_command => 'hostalive',
    target        => "/etc/icinga2/features-enabled/${icinga_agent_fqdn}.conf",
  }
}

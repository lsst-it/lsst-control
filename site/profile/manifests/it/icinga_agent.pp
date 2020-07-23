# @summary
#   Icinga agent creation for metric collections

class profile::it::icinga_agent(
  String $salt = '5a3d695b8aef8f18452fc494593056a4',
  String $icinga_master_ip = '139.229.135.31',
  String $icinga_master_fqdn = 'icinga-master.ls.lsst.org',
  String $user = 'svc_icinga',
  String $pwd = 'um0l7BmP;$WU',
)
{
  $icinga_agent_fqdn = $facts['fqdn']
  $icinga_agent_ip = $facts['ipaddress']

  $packages = [
    'nagios-plugins-all',
    'curl',
  ]
  $json_file = "{
              \"address\": ${icinga_agent_ip},
              \"display_name\": ${icinga_agent_fqdn},
              \"imports\": [
                  \"Host Template\"
              ],
              \"object_name\":${icinga_agent_fqdn},
              \"object_type\": \"object\",
              \"vars\": {
                  \"safed_profile\": \"3\"
              }
            }"
  package { $packages:
    ensure => 'present',
  }
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
    ensure          => 'present',
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
  file { "/var/tmp/${icinga_agent_fqdn}.json":
    ensure  => 'present',
    content => $json_file,
  }
}

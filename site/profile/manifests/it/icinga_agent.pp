# @summary
#   Icinga agent creation for metric collections

class profile::it::icinga_agent(
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
  $url = "https://${icinga_master_fqdn}/director/host?name=${icinga_agent_fqdn}&amp;resolved"
  $credentials = "${user}:${pwd}"
  $command = 'touch passed_unless'
  $unless = "curl -s -k -u ${credentials} -H 'Accept: application/json' -X GET ${url} | grep Failed > result"
  package { $packages:
    ensure => 'present',
  }
  class { '::icinga2':
    manage_repo => true,
    confd       => false,
    features    => ['mainlog'],
  }
  class { '::icinga2::feature::api':
    pki             => 'puppet',
    accept_config   => true,
    accept_commands => true,
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
  exec { $command:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    unless   => $unless,
  }
}


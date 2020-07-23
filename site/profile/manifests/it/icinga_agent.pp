# @summary
#   Icinga agent creation for metric collections

class profile::it::icinga_agent(
  String $icinga_master_fqdn = 'icinga-master.ls.lsst.org',
  String $icinga_master_ip = '139.229.135.31',
  String $user = 'svc_icinga',
  String $pwd = 'um0l7BmP;$WU',
  String $host_template = 'General Host Template',
)
{
  $icinga_agent_fqdn = $facts['fqdn']
  $icinga_agent_ip = $facts['ipaddress']

  $packages = [
    'nagios-plugins-all',
    'curl',
  ]
  $json_file = "{
\"address\": \"${icinga_agent_ip}\",
\"display_name\": \"${icinga_agent_fqdn}\",
\"imports\": [
  \"${host_template}\"
],
\"object_name\":\"${icinga_agent_fqdn}\",
\"object_type\": \"object\",
\"vars\": {
    \"safed_profile\": \"3\"
}
}"
  $url = "https://${icinga_master_fqdn}/director/host"
  $credentials = "${user}:${pwd}"
  $command = "curl -s -k -u '${credentials}' -H 'Accept: application/json' -X POST '${url}' -d @/var/tmp/${icinga_agent_fqdn}.json"
  $unless = "curl -s -k -u '${credentials}' -H 'Accept: application/json' -X GET '${url}/host?name=${icinga_master_fqdn}' | grep Failed"

## Create host file
  file { "/var/tmp/${icinga_agent_fqdn}.json":
    ensure  => 'present',
    content => $json_file,
  }
##Add host to master
  exec { $command:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $unless,
  }
##Add require packages
  package { $packages:
    ensure => 'present',
  }
##Icinga2 config
  class { '::icinga2':
    manage_repo => true,
    confd       => false,
    features    => ['mainlog'],
  }
##Icinga2 feature API config
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
}


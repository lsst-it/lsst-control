# @summary
#   Icinga agent creation for metric collections

class profile::it::icinga_agent(
  String $icinga_master_fqdn = 'icinga-master.ls.lsst.org',
  String $icinga_master_ip = '139.229.135.31',
  String $credentials = 'c3ZjX2ljaW5nYTp1bTBsN0JtUDskV1U=',
  String $host_template = 'GeneralHostTemplate',
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
  $cmd = "curl -s -k -H'Authorization:Basic ${credentials}' -H 'Accept: application/json' -X POST '${url}' -d @/var/tmp/${icinga_agent_fqdn}.json"
  $cond = "curl -s -k -H 'Authorization:Basic ${credentials}' -H 'Accept: application/json' -X GET '${url}/host?name=${icinga_master_fqdn}' | grep Failed"

## Create host file
  file { "/var/tmp/${icinga_agent_fqdn}.json":
    ensure  => 'present',
    content => $json_file,
  }
##Add host to master
  exec { $cmd:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $cond,
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


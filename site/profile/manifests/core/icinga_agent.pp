# @summary
#   Icinga agent creation for metric collections

class profile::core::icinga_agent(
  $icinga_master_fqdn,
  $icinga_master_ip,
  $hash,
  $host_template,
)
{
$packages = [
  'nagios-plugins-all',
  'curl',
]
$icinga_agent_fqdn = $facts['fqdn']
$icinga_agent_ip = $facts['ipaddress']
$credentials = "Authorization:Basic ${hash}"
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
$icinga_path = '/opt/icinga'
$path = "${icinga_path}/${icinga_agent_fqdn}.json"
$url = "https://${icinga_master_fqdn}/director/host"
$cmd = "curl -s -k -H '${credentials}' -H 'Accept: application/json' -X POST '${url}' -d @${path}"
$cond = "curl -s -k -H '${credentials}' -H 'Accept: application/json' -X GET '${url}/host?name=${icinga_agent_fqdn}' | grep Failed"

##Create a directory to allocate json files
file { $icinga_path:
  ensure => 'directory',
}

## Create host file
  file { $path:
    ensure  => 'present',
    content => $json_file,
  }
##Add host to master
  exec { $cmd:
    cwd      => $icinga_path,
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


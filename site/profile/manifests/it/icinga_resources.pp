# @summary
#   Define and create all file resources of icinga master

class profile::it::icinga_resources (
  $hash,
  $host_tpl,
  $http_tpl,
  $dns_tpl,
  $master_tpl,
  $ipa_tpl,
)
{

#<----------Variables Definition------------>
#Implicit usage of facts
$master_fqdn  = $facts[fqdn]
$master_ip  = $facts[ipaddress]

#Commands abreviation
$url_host    = "https://${master_fqdn}/director/host"
$url_svc     = "https://${master_fqdn}/director/service"
$credentials = "Authorization:Basic ${hash}"
$format      = 'Accept: application/json'
$curl        = 'curl -s -k -H'
$icinga_path = '/opt/icinga'
$lt          = '| grep Failed'

#Service Templates Names
$http_svc_tpl_name    = 'HttpServiceTemplate'
$ping_svc_tpl_name    = 'PingServiceTemplate'
$dns_svc_tpl_name     = 'DnsServiceTemplate'
$master_svc_tpl_name  = 'MasterServiceTemplate'
$ipa_svc_tpl_name     = 'IpaServiceTemplate'
$disk_svc_tpl_name    = 'DiskServiceTemplace'

#Service Names
$host_svc_ping_name   = 'HostPingService'
$host_svc_disk_name   = 'HostDiskService'
$dns_svc_name         = 'DnsService'
$dns_svc_ping_name    = 'DnsPingService'
$dns_svc_disk_name    = 'DnsDiskService'
$master_svc_dhcp_name = 'MasterDhcpService'
$master_svc_ping_name = 'MasterPingService'
$master_svc_disk_name = 'MasterDiskService'
$http_svc_name        = 'HttpService'
$http_svc_ping_name   = 'HttpPingService'
$http_svc_disk_name   = 'HttpDiskService'
$ipa_svc_name         = 'IpaService'
$ipa_svc_ping_name    = 'IpaPingService'
$ipa_svc_disk_name    = 'IpaDiskService'
#<--------End Variables Definition---------->
#
#
#<---------------JSON Files ---------------->
##Hosts Templates JSON
$general_template = "{
\"accept_config\": true,
\"check_command\": \"hostalive\",
\"has_agent\": true,
\"master_should_connect\": true,
\"max_check_attempts\": \"5\",
\"object_name\": \"${host_tpl}\",
\"object_type\": \"template\"
}"
$http_template = "{
\"accept_config\": true,
\"check_command\": \"hostalive\",
\"has_agent\": true,
\"master_should_connect\": true,
\"max_check_attempts\": \"5\",
\"object_name\": \"${http_tpl}\",
\"object_type\": \"template\"
}"
$dns_template = "{
\"accept_config\": true,
\"check_command\": \"hostalive\",
\"has_agent\": true,
\"master_should_connect\": true,
\"max_check_attempts\": \"5\",
\"object_name\": \"${dns_tpl}\",
\"object_type\": \"template\"
}"
$master_template = "{
\"accept_config\": true,
\"check_command\": \"hostalive\",
\"has_agent\": true,
\"master_should_connect\": true,
\"max_check_attempts\": \"5\",
\"object_name\": \"${master_tpl}\",
\"object_type\": \"template\"
}"
$ipa_template = "{
\"accept_config\": true,
\"check_command\": \"hostalive\",
\"has_agent\": true,
\"master_should_connect\": true,
\"max_check_attempts\": \"5\",
\"object_name\": \"${ipa_tpl}\",
\"object_type\": \"template\"
}"

##Service Template JSON
$http_svc_tpl = "{
\"check_command\": \"http\",
\"object_name\": \"${http_svc_tpl_name}\",
\"object_type\": \"template\",
\"use_agent\": true,
\"zone\": \"master\"
}"
$ping_svc_tpl = "{
\"check_command\": \"hostalive\",
\"object_name\": \"${ping_svc_tpl_name}\",
\"object_type\": \"template\",
\"use_agent\": true,
\"zone\": \"master\"
}"
$dns_svc_tpl = "{
\"check_command\": \"dns\",
\"object_name\": \"${dns_svc_tpl_name}\",
\"object_type\": \"template\",
\"use_agent\": true,
\"zone\": \"master\"
}"
$master_svc_tpl = "{
\"check_command\": \"dhcp\",
\"object_name\": \"${master_svc_tpl_name}\",
\"object_type\": \"template\",
\"use_agent\": true,
\"zone\": \"master\"
}"
$ipa_svc_tpl = "{
\"check_command\": \"ldap\",
\"object_name\": \"${ipa_svc_tpl_name}\",
\"object_type\": \"template\",
\"use_agent\": true,
\"vars\": {
    \"ldap_address\": \"localhost\",
    \"ldap_base\": \"dc=lsst,dc=cloud\"
},
\"zone\": \"master\"
}"
$disk_svc_tpl = "{
\"check_command\": \"disk\",
\"object_name\": \"${disk_svc_tpl_name}\",
\"object_type\": \"template\",
\"use_agent\": true,
\"vars\": {
    \"disk_cfree\": \"10%\",
    \"disk_wfree\": \"20%\"
},
\"zone\": \"master\"
}"

##Services Definition
#Ping, disk and RAM monitoring
$host_svc1 = "{
\"host\": \"${host_tpl}\",
\"imports\": [
    \"${$ping_svc_tpl_name}\"
],
\"object_name\": \"${host_svc_ping_name}\",
\"object_type\": \"object\"
}"
$host_svc2 = "{
\"host\": \"${host_tpl}\",
\"imports\": [
    \"${$disk_svc_tpl_name}\"
],
\"object_name\": \"${host_svc_disk_name}\",
\"object_type\": \"object\"
}"
#HTTP, Ping, disk and RAM monitoring
$http_svc1 = "{
\"host\": \"${http_tpl}\",
\"imports\": [
  \"${$http_svc_tpl_name}\"
],
\"object_name\": \"${http_svc_name}\",
\"object_type\": \"object\"
}"
$http_svc2 = "{
\"host\": \"${http_tpl}\",
\"imports\": [
    \"${$ping_svc_tpl_name}\"
],
\"object_name\": \"${http_svc_ping_name}\",
\"object_type\": \"object\"
}"
$http_svc3 = "{
\"host\": \"${http_tpl}\",
\"imports\": [
    \"${$disk_svc_tpl_name}\"
],
\"object_name\": \"${http_svc_disk_name}\",
\"object_type\": \"object\"
}"
#DHCP, Ping, disk and RAM monitoring
$master_svc1 = "{
\"host\": \"${master_tpl}\",
\"imports\": [
  \"${$master_svc_tpl_name}\"
],
\"object_name\": \"${master_svc_dhcp_name}\",
\"object_type\": \"object\",
\"vars\": {
  \"dhcp_serverip\": \"139.229.135.5\"
}"
$master_svc2 = "{
\"host\": \"${master_tpl}\",
\"imports\": [
  \"${$ping_svc_tpl_name}\"
],
\"object_name\": \"${master_svc_ping_name}\",
\"object_type\": \"object\"
}"
$master_svc3 = "{
\"host\": \"${master_tpl}\",
\"imports\": [
    \"${$disk_svc_tpl_name}\"
],
\"object_name\": \"${master_svc_disk_name}\",
\"object_type\": \"object\"
}"
#DNS, Ping, disk and RAM monitoring
$dns_svc1 = "{
\"host\": \"${dns_tpl}\",
\"imports\": [
  \"${$dns_svc_tpl_name}\"
],
\"object_name\": \"${dns_svc_name}\",
\"object_type\": \"object\"
}"
$dns_svc2 = "{
\"host\": \"${dns_tpl}\",
\"imports\": [
  \"${$ping_svc_tpl_name}\"
],
\"object_name\": \"${dns_svc_ping_name}\",
\"object_type\": \"object\"
}"
$dns_svc3 = "{
\"host\": \"${dns_tpl}\",
\"imports\": [
    \"${$disk_svc_tpl_name}\"
],
\"object_name\": \"${dns_svc_disk_name}\",
\"object_type\": \"object\"
}"
#IPA, Ping, disk and RAM monitoring
$ipa_svc1 = "{
\"host\": \"${ipa_tpl}\",
\"imports\": [
  \"${$ipa_svc_tpl_name}\"
],
\"object_name\": \"${ipa_svc_name}\",
\"object_type\": \"object\"
}"
$ipa_svc2 = "{
\"host\": \"${ipa_tpl}\",
\"imports\": [
  \"${$ping_svc_tpl_name}\"
],
\"object_name\": \"${ipa_svc_ping_name}\",
\"object_type\": \"object\"
}"
$ipa_svc3 = "{
\"host\": \"${ipa_tpl}\",
\"imports\": [
    \"${$disk_svc_tpl_name}\"
],
\"object_name\": \"${ipa_svc_disk_name}\",
\"object_type\": \"object\"
}"

##Master Node JSON
  $add_master_host = "{
\"address\": \"${master_ip}\",
\"display_name\": \"${master_fqdn}\",
\"imports\": [
  \"${master_tpl}\"
],
\"object_name\":\"${master_fqdn}\",
\"object_type\": \"object\",
\"vars\": {
    \"safed_profile\": \"3\"
}
}"
#<------------End JSON Files --------------->
#
#
#<----------Templates Creation-------------->
#Host Templates Creation
$host_tpl_path = "${$icinga_path}/${host_tpl}.json"
$host_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${host_tpl}' ${lt}"
$host_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${host_tpl_path}"

$http_tpl_path = "${icinga_path}/${http_tpl}.json"
$http_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${http_tpl}' ${lt}"
$http_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${http_tpl_path}"

$dns_tpl_path = "${icinga_path}/${dns_tpl}.json"
$dns_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${dns_tpl}' ${lt}"
$dns_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${dns_tpl_path}"

$master_tpl_path = "${icinga_path}/${master_tpl}.json"
$master_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${master_tpl}' ${lt}"
$master_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${master_tpl_path}"

$ipa_tpl_path = "${icinga_path}/${ipa_tpl}.json"
$ipa_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${ipa_tpl}' ${lt}"
$ipa_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${ipa_tpl_path}"

#Services Template Creation
$http_svc_tpl_path = "${icinga_path}/${http_svc_tpl_name}.json"
$http_svc_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_tpl_name}' ${lt}"
$http_svc_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$http_svc_tpl_path}"

$ping_svc_tpl_path = "${icinga_path}/${ping_svc_tpl_name}.json"
$ping_svc_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ping_svc_tpl_name}' ${lt}"
$ping_svc_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$ping_svc_tpl_path}"

$dns_svc_tpl_path  = "${icinga_path}/${dns_svc_tpl_name}.json"
$dns_svc_tpl_cond  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_tpl_name}' ${lt}"
$dns_svc_tpl_cmd   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$dns_svc_tpl_path}"

$master_svc_tpl_path = "${icinga_path}/${master_svc_tpl_name}.json"
$master_svc_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_tpl_name}' ${lt}"
$master_svc_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$master_svc_tpl_path}"

$ipa_svc_tpl_path = "${icinga_path}/${ipa_svc_tpl_name}.json"
$ipa_svc_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_tpl_name}' ${lt}"
$ipa_svc_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$ipa_svc_tpl_path}"

$disk_svc_tpl_path = "${icinga_path}/${disk_svc_tpl_name}.json"
$disk_svc_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${disk_svc_tpl_name}' ${lt}"
$disk_svc_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$disk_svc_tpl_path}"

#Services Creation
$host_svc_path1 = "${icinga_path}/${host_svc_ping_name}.json"
$host_svc_cond1 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${host_svc_ping_name}&host=${host_tpl}' ${lt}"
$host_svc_cmd1  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${host_svc_path1}"
$host_svc_path2 = "${icinga_path}/${host_svc_disk_name}.json"
$host_svc_cond2 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${host_svc_disk_name}&host=${host_tpl}' ${lt}"
$host_svc_cmd2  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${host_svc_path2}"

$http_svc_path1 = "${icinga_path}/${http_svc_name}.json"
$http_svc_cond1 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_name}&host=${http_tpl}' ${lt}"
$http_svc_cmd1  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path1}"
$http_svc_path2 = "${icinga_path}/${http_svc_ping_name}.json"
$http_svc_cond2 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_ping_name}&host=${http_tpl}' ${lt}"
$http_svc_cmd2  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path2}"
$http_svc_path3 = "${icinga_path}/${http_svc_disk_name}.json"
$http_svc_cond3 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_disk_name}&host=${http_tpl}' ${lt}"
$http_svc_cmd3  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path3}"

$dns_svc_path1  = "${icinga_path}/${dns_svc_name}.json"
$dns_svc_cond1  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_name}&host=${dns_tpl}' ${lt}"
$dns_svc_cmd1   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path1}"
$dns_svc_path2  = "${icinga_path}/${dns_svc_ping_name}.json"
$dns_svc_cond2  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_ping_name}&host=${dns_tpl}' ${lt}"
$dns_svc_cmd2   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path2}"
$dns_svc_path3  = "${icinga_path}/${dns_svc_disk_name}.json"
$dns_svc_cond3  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_disk_name}&host=${dns_tpl}' ${lt}"
$dns_svc_cmd3   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path3}"

$master_svc_path1 = "${icinga_path}/${master_svc_dhcp_name}.json"
$master_svc_cond1 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_dhcp_name}&host=${master_tpl}' ${lt}"
$master_svc_cmd1  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path1}"
$master_svc_path2 = "${icinga_path}/${master_svc_ping_name}.json"
$master_svc_cond2 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_ping_name}&host=${master_tpl}' ${lt}"
$master_svc_cmd2  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path2}"
$master_svc_path3 = "${icinga_path}/${master_svc_disk_name}.json"
$master_svc_cond3 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_disk_name}&host=${master_tpl}' ${lt}"
$master_svc_cmd3  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path3}"

$ipa_svc_path1  = "${icinga_path}/${ipa_svc_name}.json"
$ipa_svc_cond1  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_name}&host=${ipa_tpl}' ${lt}"
$ipa_svc_cmd1   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${ipa_svc_path1}"
$ipa_svc_path2  = "${icinga_path}/${ipa_svc_ping_name}.json"
$ipa_svc_cond2  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_ping_name}&host=${ipa_tpl}' ${lt}"
$ipa_svc_cmd2   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${ipa_svc_path2}"
$ipa_svc_path3  = "${icinga_path}/${ipa_svc_disk_name}.json"
$ipa_svc_cond3  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_disk_name}&host=${ipa_tpl}' ${lt}"
$ipa_svc_cmd3   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${ipa_svc_path3}"

#Master Host Creation
$addhost_path = "${icinga_path}/${master_fqdn}.json"
$addhost_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${master_fqdn}' ${lt}"
$addhost_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${addhost_path}"

#<---------End Templates Creation----------->
#
#
#<-----Files Creation and deployement------->

#Create a directory to allocate json files
file { $icinga_path:
  ensure => 'directory',
}

##Host Templates
#Create host template file
  file { $host_tpl_path:
    ensure  => 'present',
    content => $general_template,
    before  => Exec[$host_tpl_cmd],
  }
#Add general host template
  exec { $host_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $host_tpl_cond,
  }
#Create http template file
  file { $http_tpl_path:
    ensure  => 'present',
    content => $http_template,
    before  => Exec[$http_tpl_cmd],
  }
#Add http template
  exec { $http_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_tpl_cond,
  }
#Create dns template file
  file { $dns_tpl_path:
    ensure  => 'present',
    content => $dns_template,
    before  => Exec[$dns_tpl_cmd],
  }
#Add dns template
  exec { $dns_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_tpl_cond,
  }
#Create dhcp file
  file { $master_tpl_path:
    ensure  => 'present',
    content => $master_template,
    before  => Exec[$master_tpl_cmd],
  }
#Add dhcp template
  exec { $master_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_tpl_cond,
  }
#Create ipa file
  file { $ipa_tpl_path:
    ensure  => 'present',
    content => $ipa_template,
    before  => Exec[$ipa_tpl_cmd],
  }
#Add ipa template
  exec { $ipa_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ipa_tpl_cond,
  }

##Service Templates
#Create http template file
  file { $http_svc_tpl_path:
    ensure  => 'present',
    content => $http_svc_tpl,
    before  => Exec[$http_svc_tpl_cmd],
  }
#Add http template
  exec { $http_svc_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_svc_tpl_cond,
  }
#Create ping template file
  file { $ping_svc_tpl_path:
    ensure  => 'present',
    content => $ping_svc_tpl,
    before  => Exec[$ping_svc_tpl_cmd],
  }
#Add http template
  exec { $ping_svc_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ping_svc_tpl_cond,
  }
#Create dhcp template file
  file { $master_svc_tpl_path:
    ensure  => 'present',
    content => $master_svc_tpl,
    before  => Exec[$master_svc_tpl_cmd],
  }
#Add http template
  exec { $master_svc_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_svc_tpl_cond,
  }
#Create dns template file 
  file { $dns_svc_tpl_path:
    ensure  => 'present',
    content => $dns_svc_tpl,
    before  => Exec[$dns_svc_tpl_cmd],
  }
#Add dns template
  exec { $dns_svc_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_svc_tpl_cond,
  }
#Create ipa template file 
  file { $ipa_svc_tpl_path:
    ensure  => 'present',
    content => $ipa_svc_tpl,
    before  => Exec[$ipa_svc_tpl_cmd],
  }
#Add ipa template
  exec { $ipa_svc_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ipa_svc_tpl_cond,
  }
#Create disk template file 
  file { $disk_svc_tpl_path:
    ensure  => 'present',
    content => $disk_svc_tpl,
    before  => Exec[$disk_svc_tpl_cmd],
  }
#Add disk template
  exec { $disk_svc_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $disk_svc_tpl_cond,
  }

##Services Definition
#Creates ping resource file for HostTemplate and PingServiceTemplate
  file { $host_svc_path1:
    ensure  => 'present',
    content => $host_svc1,
    before  => Exec[$host_svc_cmd1],
  }
#Adds ping resource file for HostTemplate and PingServiceTemplate
  exec { $host_svc_cmd1:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $host_svc_cond1,
  }
#Creates disk resource file for HostTemplate and DiskServiceTemplate
  file { $host_svc_path2:
    ensure  => 'present',
    content => $host_svc2,
    before  => Exec[$host_svc_cmd2],
  }
#Adds disk resource file for HostTemplate and DiskServiceTemplate
  exec { $host_svc_cmd2:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $host_svc_cond2,
  }

#Creates http resource file for HttpTemplate and HttpServiceTemplate
  file { $http_svc_path1:
    ensure  => 'present',
    content => $http_svc1,
    before  => Exec[$http_svc_cmd1],
  }
#Adds http resource file for HttpTemplate and HttpServiceTemplate
  exec { $http_svc_cmd1:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_svc_cond1,
  }
#Creates ping resource file for HttpTemplate and PingServiceTemplate
  file { $http_svc_path2:
    ensure  => 'present',
    content => $http_svc2,
    before  => Exec[$http_svc_cmd2],
  }
#Adds ping resource file for HttpTemplate and PingServiceTemplate
  exec { $http_svc_cmd2:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_svc_cond2,
  }
#Creates disk resource file for HttpTemplate and DiskServiceTemplate
  file { $http_svc_path3:
    ensure  => 'present',
    content => $http_svc3,
    before  => Exec[$http_svc_cmd3],
  }
#Adds disk resource file for HttpTemplate and DiskServiceTemplate
  exec { $http_svc_cmd3:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_svc_cond3,
  }

#Creates dhcp resource file for MasterTemplate and DhcpServiceTemplate
  file { $master_svc_path1:
    ensure  => 'present',
    content => $master_svc1,
    before  => Exec[$master_svc_cmd1],
  }
#Adds dhcp resource file for MasterTemplate and DhcpServiceTemplate
  exec { $master_svc_cmd1:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_svc_cond1,
  }
#Creates ping resource file for MasterTemplate and PingServiceTemplate
  file { $master_svc_path2:
    ensure  => 'present',
    content => $master_svc2,
    before  => Exec[$master_svc_cmd2],
  }
#Adds ping resource file for MasterTemplate and PingServiceTemplate
  exec { $master_svc_cmd2:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_svc_cond2,
  }
#Creates disk resource file for MasterTemplate and DiskServiceTemplate
  file { $master_svc_path3:
    ensure  => 'present',
    content => $master_svc3,
    before  => Exec[$master_svc_cmd3],
  }
#Adds disk resource file for MasterTemplate and DiskServiceTemplate
  exec { $master_svc_cmd3:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_svc_cond3,
  }

#Creates dns resource file for DnsTemplate and DnsServiceTemplate
  file { $dns_svc_path1:
    ensure  => 'present',
    content => $dns_svc1,
    before  => Exec[$dns_svc_cmd1],
  }
#Adds dns resource file for DnsTemplate and DnsServiceTemplate
  exec { $dns_svc_cmd1:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_svc_cond1,
  }
#Creates ping resource file for DnsTemplate and PingServiceTemplate
  file { $dns_svc_path2:
    ensure  => 'present',
    content => $dns_svc2,
    before  => Exec[$dns_svc_cmd2],
  }
#Adds ping resource file for DnsTemplate and PingServiceTemplate
  exec { $dns_svc_cmd2:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_svc_cond2,
  }
#Creates disk resource file for DnsTemplate and DiskServiceTemplate
  file { $dns_svc_path3:
    ensure  => 'present',
    content => $dns_svc3,
    before  => Exec[$dns_svc_cmd3],
  }
#Adds disk resource file for DnsTemplate and DiskServiceTemplate
  exec { $dns_svc_cmd3:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_svc_cond3,
  }

#Creates ipa resource file for IpaTemplate and IpaServiceTemplate
  file { $ipa_svc_path1:
    ensure  => 'present',
    content => $ipa_svc1,
    before  => Exec[$ipa_svc_cmd1],
  }
#Adds ipa resource file for IpaTemplate and IpaServiceTemplate
  exec { $ipa_svc_cmd1:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ipa_svc_cond1,
  }
#Creates ping resource file for IpaTemplate and PingServiceTemplate
  file { $ipa_svc_path2:
    ensure  => 'present',
    content => $ipa_svc2,
    before  => Exec[$dns_svc_cmd2],
  }
#Adds ping resource file for IpaTemplate and PingServiceTemplate
  exec { $ipa_svc_cmd2:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ipa_svc_cond2,
  }
#Creates disk resource file for IpaTemplate and DiskServiceTemplate
  file { $ipa_svc_path3:
    ensure  => 'present',
    content => $ipa_svc3,
    before  => Exec[$ipa_svc_cmd3],
  }
#Adds disk resource file for IpaTemplate and DiskServiceTemplate
  exec { $ipa_svc_cmd3:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ipa_svc_cond3,
  }

##Add Master Host
#Create master host file
  file { $addhost_path:
    ensure  => 'present',
    content => $add_master_host,
    before  => Exec[$addhost_cmd],
  }
#Add master host
  exec { $addhost_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $addhost_cond,
  }
#<------END Files Creation and deployement--------->
}

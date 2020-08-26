# @summary
#   Define and create all file resources of icinga master

class profile::core::icinga_resources (
  String $credentials_hash,
  String $host_template,
  String $http_template,
  String $dns_template,
  String $master_template,
  String $ipa_template,
  String $tls_template,
  String $dhcp_server,
){

  #<----------Variables Definition------------>
  #Implicit usage of facts
  $master_fqdn  = $facts[fqdn]
  $master_ip  = $facts[ipaddress]

  #Commands abreviation
  $url_host    = "https://${master_fqdn}/director/host"
  $url_svc     = "https://${master_fqdn}/director/service"
  $credentials = "Authorization:Basic ${credentials_hash}"
  $format      = 'Accept: application/json'
  $curl        = 'curl -s -k -H'
  $icinga_path = '/opt/icinga'
  $lt          = '| grep Failed'

  #Service Templates Names
  $http_svc_template_name    = 'HttpServiceTemplate'
  $ping_svc_template_name    = 'PingServiceTemplate'
  $dns_svc_template_name     = 'DnsServiceTemplate'
  $master_svc_template_name  = 'MasterServiceTemplate'
  $ipa_svc_template_name     = 'IpaServiceTemplate'
  $disk_svc_template_name    = 'DiskServiceTemplace'

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
  $general_template_content = @("GENERAL"/L)
    {
    "accept_config": true,
    "check_command": "hostalive",
    "has_agent": true,
    "master_should_connect": true,
    "max_check_attempts": "5",
    "object_name": "${host_template}",
    "object_type": "template"
    }
    | GENERAL
  $http_template_content = @("HTTP"/L)
    {
    "accept_config": true,
    "check_command": "hostalive",
    "has_agent": true,
    "master_should_connect": true,
    "max_check_attempts": "5",
    "object_name": "${http_template}",
    "object_type": "template"
    }
    | HTTP
  $dns_template_content = @("DNS"/L)
    {
    "accept_config": true,
    "check_command": "hostalive",
    "has_agent": true,
    "master_should_connect": true,
    "max_check_attempts": "5",
    "object_name": "${dns_template}",
    "object_type": "template"
    }
    | DNS
  $master_template_content = @("MASTER"/L)
    {
    "accept_config": true,
    "check_command": "hostalive",
    "has_agent": true,
    "master_should_connect": true,
    "max_check_attempts": "5",
    "object_name": "${master_template}",
    "object_type": "template"
    }
    | MASTER
  $ipa_template_content = @("IPA"/L)
    {
    "accept_config": true,
    "check_command": "hostalive",
    "has_agent": true,
    "master_should_connect": true,
    "max_check_attempts": "5",
    "object_name": "${ipa_template}",
    "object_type": "template"
    }
    | IPA
  $tls_template_content = @("TLS"/L)
    {
    "accept_config": false,
    "check_command": "http",
    "has_agent": false,
    "master_should_connect": false,
    "max_check_attempts": "5",
    "object_name": "${tls_template}",
    "object_type": "template",
        "vars": {
        "http_certificate": "30"
        },
    }
    | TLS
  
  ##Service Template JSON
  $http_svc_template = @("HTTP_TEMPLATE"/L)
    {
    "check_command": "http",
    "object_name": "${http_svc_template_name}",
    "object_type": "template",
    "use_agent": true,
    "zone": "master"
    }
    | HTTP_TEMPLATE
  $ping_svc_template = @("PING_TEMPLATE"/L)
    {
    "check_command": "hostalive",
    "object_name": "${ping_svc_template_name}",
    "object_type": "template",
    "use_agent": true,
    "zone": "master"
    }
    | PING_TEMPLATE
  $dns_svc_template = @("DNS_TEMPLATE"/L)
    {
    "check_command": "dns",
    "object_name": "${dns_svc_template_name}",
    "object_type": "template",
    "use_agent": true,
    "zone": "master"
    }
    | DNS_TEMPLATE
  $master_svc_template = @("MASTER_TEMPLATE"/L)
    {
    "check_command": "dhcp",
    "object_name": "${master_svc_template_name}",
    "object_type": "template",
    "use_agent": true,
    "zone": "master"
    }
    | MASTER_TEMPLATE
  $ipa_svc_template = @("IPA_TEMPLATE"/L)
    {
    "check_command": "ldap",
    "object_name": "${ipa_svc_template_name}",
    "object_type": "template",
    "use_agent": true,
    "vars": {
        "ldap_address": "localhost",
        "ldap_base": "dc=lsst,dc=cloud"
    },
    "zone": "master"
    }
    | IPA_TEMPLATE
  $disk_svc_template = @("DISK_TEMPLATE"/L)
    {
    "check_command": "disk",
    "object_name": "${disk_svc_template_name}",
    "object_type": "template",
    "use_agent": true,
    "vars": {
        "disk_cfree": "10%",
        "disk_wfree": "20%"
    },
    "zone": "master"
    }
    | DISK_TEMPLATE
  ##Services Definition
  #Ping, disk and RAM monitoring
  $host_svc1 = @("HOST_SVC_1"/L)
    {
    "host": "${host_template}",
    "imports": [
        "${$ping_svc_template_name}"
    ],
    "object_name": "${host_svc_ping_name}",
    "object_type": "object"
    }
    | HOST_SVC_1
  $host_svc2 = @("HOST_SVC_2"/L)
    {
    "host": "${host_template}",
    "imports": [
        "${$disk_svc_template_name}"
    ],
    "object_name": "${host_svc_disk_name}",
    "object_type": "object"
    }
    | HOST_SVC_2
  #HTTP, Ping, disk and RAM monitoring
  $http_svc1 = @("HTTP_SVC_1"/L)
    {
    "host": "${http_template}",
    "imports": [
      "${$http_svc_template_name}"
    ],
    "object_name": "${http_svc_name}",
    "object_type": "object"
    }
    | HTTP_SVC_1
  $http_svc2 = @("HTTP_SVC_2"/L)
    {
    "host": "${http_template}",
    "imports": [
        "${$ping_svc_template_name}"
    ],
    "object_name": "${http_svc_ping_name}",
    "object_type": "object"
    }
    | HTTP_SVC_2
  $http_svc3 = @("HTTP_SVC_3"/L)
    {
    "host": "${http_template}",
    "imports": [
        "${$disk_svc_template_name}"
    ],
    "object_name": "${http_svc_disk_name}",
    "object_type": "object"
    }
    | HTTP_SVC_3
  #DHCP, Ping, disk and RAM monitoring
  $master_svc1 = @("MASTER_SVC_1"/L)
    {
    "host": "${master_template}",
    "imports": [
      "${$master_svc_template_name}"
    ],
    "object_name": "${master_svc_dhcp_name}",
    "object_type": "object",
    "vars": {
      "dhcp_serverip": "${dhcp_server}"
    }
    }
    | MASTER_SVC_1
  $master_svc2 = @("MASTER_SVC_2"/L)
    {
    "host": "${master_template}",
    "imports": [
      "${$ping_svc_template_name}"
    ],
    "object_name": "${master_svc_ping_name}",
    "object_type": "object"
    }
    | MASTER_SVC_2
  $master_svc3 = @("MASTER_SVC_3"/L)
    {
    "host": "${master_template}",
    "imports": [
        "${$disk_svc_template_name}"
    ],
    "object_name": "${master_svc_disk_name}",
    "object_type": "object"
    }
    | MASTER_SVC_3
  #DNS, Ping, disk and RAM monitoring
  $dns_svc1 = @("DNS_SVC_1"/L)
    {
    "host": "${dns_template}",
    "imports": [
      "${$dns_svc_template_name}"
    ],
    "object_name": "${dns_svc_name}",
    "object_type": "object"
    }
    | DNS_SVC_1
  $dns_svc2 = @("DNS_SVC_2"/L)
    {
    "host": "${dns_template}",
    "imports": [
      "${$ping_svc_template_name}"
    ],
    "object_name": "${dns_svc_ping_name}",
    "object_type": "object"
    }
    | DNS_SVC_2
  $dns_svc3 = @("DNS_SVC_3"/L)
    {
    "host": "${dns_template}",
    "imports": [
        "${$disk_svc_template_name}"
    ],
    "object_name": "${dns_svc_disk_name}",
    "object_type": "object"
    }
    | DNS_SVC_3
  #IPA, Ping, disk and RAM monitoring
  $ipa_svc1 = @("IPA_SVC_1"/L)
    {
    "host": "${ipa_template}",
    "imports": [
      "${$ipa_svc_template_name}"
    ],
    "object_name": "${ipa_svc_name}",
    "object_type": "object"
    }
    | IPA_SVC_1
  $ipa_svc2 = @(IPA_SVC_2/L)
    {
    "host": "${ipa_template}",
    "imports": [
      "${$ping_svc_template_name}"
    ],
    "object_name": "${ipa_svc_ping_name}",
    "object_type": "object"
    }
    | IPA_SVC_2
  $ipa_svc3 = @("IPA_SVC_3"/L)
    {
    "host": "${ipa_template}",
    "imports": [
        "${$disk_svc_template_name}"
    ],
    "object_name": "${ipa_svc_disk_name}",
    "object_type": "object"
    }
    | IPA_SVC_3
  ##Master Node JSON
  $add_master_host = @("MASTER_HOST"/L)
    {
    "address": "${master_ip}",
    "display_name": "${master_fqdn}",
    "imports": [
      "${master_template}"
    ],
    "object_name":"${master_fqdn}",
    "object_type": "object",
    "vars": {
        "safed_profile": "3"
    }
    }
    | MASTER_HOST
  #<------------End JSON Files --------------->
  #
  #
  #<----------Templates Creation-------------->
  #Host Templates Creation
  $host_template_path = "${$icinga_path}/${host_template}.json"
  $host_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${host_template}' ${lt}"
  $host_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${host_template_path}"

  $http_template_path = "${icinga_path}/${http_template}.json"
  $http_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${http_template}' ${lt}"
  $http_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${http_template_path}"

  $dns_template_path = "${icinga_path}/${dns_template}.json"
  $dns_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${dns_template}' ${lt}"
  $dns_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${dns_template_path}"

  $master_template_path = "${icinga_path}/${master_template}.json"
  $master_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${master_template}' ${lt}"
  $master_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${master_template_path}"

  $ipa_template_path = "${icinga_path}/${ipa_template}.json"
  $ipa_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${ipa_template}' ${lt}"
  $ipa_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${ipa_template_path}"

  $tls_template_path = "${icinga_path}/${tls_template}.json"
  $tls_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${tls_template}' ${lt}"
  $tls_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${tls_template_path}"

  #Services Template Creation
  $http_svc_template_path = "${icinga_path}/${http_svc_template_name}.json"
  $http_svc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_template_name}' ${lt}"
  $http_svc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$http_svc_template_path}"

  $ping_svc_template_path = "${icinga_path}/${ping_svc_template_name}.json"
  $ping_svc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ping_svc_template_name}' ${lt}"
  $ping_svc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$ping_svc_template_path}"

  $dns_svc_template_path  = "${icinga_path}/${dns_svc_template_name}.json"
  $dns_svc_template_cond  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_template_name}' ${lt}"
  $dns_svc_template_cmd   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$dns_svc_template_path}"

  $master_svc_template_path = "${icinga_path}/${master_svc_template_name}.json"
  $master_svc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_template_name}' ${lt}"
  $master_svc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$master_svc_template_path}"

  $ipa_svc_template_path = "${icinga_path}/${ipa_svc_template_name}.json"
  $ipa_svc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_template_name}' ${lt}"
  $ipa_svc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$ipa_svc_template_path}"

  $disk_svc_template_path = "${icinga_path}/${disk_svc_template_name}.json"
  $disk_svc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${disk_svc_template_name}' ${lt}"
  $disk_svc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$disk_svc_template_path}"

  #Services Creation
  $host_svc_path1 = "${icinga_path}/${host_svc_ping_name}.json"
  $host_svc_cond1 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${host_svc_ping_name}&host=${host_template}' ${lt}"
  $host_svc_cmd1  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${host_svc_path1}"
  $host_svc_path2 = "${icinga_path}/${host_svc_disk_name}.json"
  $host_svc_cond2 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${host_svc_disk_name}&host=${host_template}' ${lt}"
  $host_svc_cmd2  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${host_svc_path2}"

  $http_svc_path1 = "${icinga_path}/${http_svc_name}.json"
  $http_svc_cond1 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_name}&host=${http_template}' ${lt}"
  $http_svc_cmd1  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path1}"
  $http_svc_path2 = "${icinga_path}/${http_svc_ping_name}.json"
  $http_svc_cond2 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_ping_name}&host=${http_template}' ${lt}"
  $http_svc_cmd2  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path2}"
  $http_svc_path3 = "${icinga_path}/${http_svc_disk_name}.json"
  $http_svc_cond3 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_disk_name}&host=${http_template}' ${lt}"
  $http_svc_cmd3  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path3}"

  $dns_svc_path1  = "${icinga_path}/${dns_svc_name}.json"
  $dns_svc_cond1  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_name}&host=${dns_template}' ${lt}"
  $dns_svc_cmd1   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path1}"
  $dns_svc_path2  = "${icinga_path}/${dns_svc_ping_name}.json"
  $dns_svc_cond2  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_ping_name}&host=${dns_template}' ${lt}"
  $dns_svc_cmd2   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path2}"
  $dns_svc_path3  = "${icinga_path}/${dns_svc_disk_name}.json"
  $dns_svc_cond3  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_disk_name}&host=${dns_template}' ${lt}"
  $dns_svc_cmd3   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path3}"

  $master_svc_path1 = "${icinga_path}/${master_svc_dhcp_name}.json"
  $master_svc_cond1 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_dhcp_name}&host=${master_template}' ${lt}"
  $master_svc_cmd1  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path1}"
  $master_svc_path2 = "${icinga_path}/${master_svc_ping_name}.json"
  $master_svc_cond2 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_ping_name}&host=${master_template}' ${lt}"
  $master_svc_cmd2  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path2}"
  $master_svc_path3 = "${icinga_path}/${master_svc_disk_name}.json"
  $master_svc_cond3 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_disk_name}&host=${master_template}' ${lt}"
  $master_svc_cmd3  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path3}"

  $ipa_svc_path1  = "${icinga_path}/${ipa_svc_name}.json"
  $ipa_svc_cond1  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_name}&host=${ipa_template}' ${lt}"
  $ipa_svc_cmd1   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${ipa_svc_path1}"
  $ipa_svc_path2  = "${icinga_path}/${ipa_svc_ping_name}.json"
  $ipa_svc_cond2  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_ping_name}&host=${ipa_template}' ${lt}"
  $ipa_svc_cmd2   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${ipa_svc_path2}"
  $ipa_svc_path3  = "${icinga_path}/${ipa_svc_disk_name}.json"
  $ipa_svc_cond3  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_disk_name}&host=${ipa_template}' ${lt}"
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
  file { $host_template_path:
    ensure  => 'present',
    content => $general_template_content,
    before  => Exec[$host_template_cmd],
  }
  #Add general host template
  exec { $host_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $host_template_cond,
    loglevel => debug,
  }
  #Create http template file
  file { $http_template_path:
    ensure  => 'present',
    content => $http_template_content,
    before  => Exec[$http_template_cmd],
  }
  #Add http template
  exec { $http_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_template_cond,
    loglevel => debug,
  }
  #Create dns template file
  file { $dns_template_path:
    ensure  => 'present',
    content => $dns_template_content,
    before  => Exec[$dns_template_cmd],
  }
  #Add dns template
  exec { $dns_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_template_cond,
    loglevel => debug,
  }
  #Create dhcp file
  file { $master_template_path:
    ensure  => 'present',
    content => $master_template_content,
    before  => Exec[$master_template_cmd],
  }
  #Add dhcp template
  exec { $master_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_template_cond,
    loglevel => debug,
  }
  #Create ipa file
  file { $ipa_template_path:
    ensure  => 'present',
    content => $ipa_template_content,
    before  => Exec[$ipa_template_cmd],
  }
  #Add ipa template
  exec { $ipa_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ipa_template_cond,
    loglevel => debug,
  }
  #Create tls cert expiration file
  file { $tls_template_path:
    ensure  => 'present',
    content => $tls_template_content,
    before  => Exec[$tls_template_cmd],
  }
  #Add tls cert expiration template
  exec { $tls_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $tls_template_cond,
    loglevel => debug,
  }

  ##Service Templates
  #Create http template file
  file { $http_svc_template_path:
    ensure  => 'present',
    content => $http_svc_template,
    before  => Exec[$http_svc_template_cmd],
  }
  #Add http template
  exec { $http_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_svc_template_cond,
    loglevel => debug,
  }
  #Create ping template file
  file { $ping_svc_template_path:
    ensure  => 'present',
    content => $ping_svc_template,
    before  => Exec[$ping_svc_template_cmd],
  }
  #Add http template
  exec { $ping_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ping_svc_template_cond,
    loglevel => debug,
  }
  #Create dhcp template file
  file { $master_svc_template_path:
    ensure  => 'present',
    content => $master_svc_template,
    before  => Exec[$master_svc_template_cmd],
  }
  #Add http template
  exec { $master_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_svc_template_cond,
    loglevel => debug,
  }
  #Create dns template file 
  file { $dns_svc_template_path:
    ensure  => 'present',
    content => $dns_svc_template,
    before  => Exec[$dns_svc_template_cmd],
  }
  #Add dns template
  exec { $dns_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_svc_template_cond,
    loglevel => debug,
  }
  #Create ipa template file 
  file { $ipa_svc_template_path:
    ensure  => 'present',
    content => $ipa_svc_template,
    before  => Exec[$ipa_svc_template_cmd],
  }
  #Add ipa template
  exec { $ipa_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ipa_svc_template_cond,
    loglevel => debug,
  }
  #Create disk template file 
  file { $disk_svc_template_path:
    ensure  => 'present',
    content => $disk_svc_template,
    before  => Exec[$disk_svc_template_cmd],
  }
  #Add disk template
  exec { $disk_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $disk_svc_template_cond,
    loglevel => debug,
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
    loglevel => debug,
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
    loglevel => debug,
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
    loglevel => debug,
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
    loglevel => debug,
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
    loglevel => debug,
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
    loglevel => debug,
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
    loglevel => debug,
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
    loglevel => debug,
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
    loglevel => debug,
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
    loglevel => debug,
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
    loglevel => debug,
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
    loglevel => debug,
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
    loglevel => debug,
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
    loglevel => debug,
  }
  #Change permissions to plugin
  file { '/usr/lib64/nagios/plugins/check_dhcp':
    owner => 'root',
    group => 'nagios',
    mode  => '4755',
  }
  file { '/usr/lib64/nagios/plugins/check_disk':
    owner => 'root',
    group => 'nagios',
    mode  => '4755',
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
    loglevel => debug,
  }
  #<------END Files Creation and deployement--------->
}

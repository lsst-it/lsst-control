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
  $url_host      = "https://${master_fqdn}/director/host"
  $url_svc       = "https://${master_fqdn}/director/service"
  $url_hostgroup = "https://${master_fqdn}/director/hostgroup"
  $credentials   = "Authorization:Basic ${credentials_hash}"
  $format        = 'Accept: application/json'
  $curl          = 'curl -s -k -H'
  $icinga_path   = '/opt/icinga'
  $lt            = '| grep Failed'

  #Service Templates Names
  $http_svc_template_name   = 'HttpServiceTemplate'
  $ping_svc_template_name   = 'PingServiceTemplate'
  $dns_svc_template_name    = 'DnsServiceTemplate'
  $master_svc_template_name = 'MasterServiceTemplate'
  $ipa_svc_template_name    = 'IpaServiceTemplate'
  $disk_svc_template_name   = 'DiskServiceTemplace'
  $tls_svc_template_name    = 'TlsServiceTemplate'
  $ssh_svc_template_name    = 'SshServiceTemplace'
  $ntp_svc_template_name    = 'NtpServiceTemplate'

  #Service Names
  $host_svc_ping_name   = 'HostPingService'
  $host_svc_disk_name   = 'HostDiskService'
  $host_svc_ssh_name    = 'HostSshService'
  $host_svc_ntp_name    = 'HostNtpService'
  $dns_svc_name         = 'DnsService'
  $dns_svc_ping_name    = 'DnsPingService'
  $dns_svc_disk_name    = 'DnsDiskService'
  $dns_svc_ssh_name     = 'DnsSshService'
  $dns_svc_ntp_name     = 'DnsNtpService'
  $master_svc_dhcp_name = 'MasterDhcpService'
  $master_svc_ping_name = 'MasterPingService'
  $master_svc_disk_name = 'MasterDiskService'
  $master_svc_tls_name  = 'MasterTlsService'
  $master_svc_ssh_name  = 'MasterSshService'
  $master_svc_ntp_name  = 'MasterNtpService'
  $http_svc_name        = 'HttpService'
  $http_svc_ping_name   = 'HttpPingService'
  $http_svc_disk_name   = 'HttpDiskService'
  $http_svc_ssh_name    = 'HttpSshService'
  $http_svc_ntp_name    = 'HttpNtpService'
  $ipa_svc_name         = 'IpaService'
  $ipa_svc_ping_name    = 'IpaPingService'
  $ipa_svc_disk_name    = 'IpaDiskService'
  $ipa_svc_ssh_name     = 'IpaSshService'
  $ipa_svc_ntp_name     = 'IpaNtpService'

  #Host Groups Names
  $antu     = 'antu_cluster'
  $ruka     = 'ruka_cluster'
  $kueyen   = 'kueyen_cluster'
  $core     = 'core_cluster'
  $comcam   = 'comcam_cluster'
  $ls_nodes = 'ls_nodes'
  $it_svc   = 'it_services'

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
    "vars": {
        "enable_pagerduty": "true"
    },
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
    "vars": {
        "enable_pagerduty": "true"
    },
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
    "vars": {
        "enable_pagerduty": "true"
    },
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
    "vars": {
        "enable_pagerduty": "true"
    },
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
    "vars": {
        "enable_pagerduty": "true"
    },
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
    "vars": {
        "http_certificate": "30",
        "enable_pagerduty": "true"
    },
    "object_name": "${tls_template}",
    "object_type": "template",
    }
    | TLS

  ##Service Template JSON
  $http_svc_template = @("HTTP_TEMPLATE"/L)
    {
    "check_command": "http",
    "object_name": "${http_svc_template_name}",
    "object_type": "template",
    "vars": {
        "enable_pagerduty": "true"
    },
    "use_agent": true,
    "zone": "master"
    }
    | HTTP_TEMPLATE
  $ping_svc_template = @("PING_TEMPLATE"/L)
    {
    "check_command": "hostalive",
    "object_name": "${ping_svc_template_name}",
    "object_type": "template",
    "vars": {
        "enable_pagerduty": "true"
    },
    "use_agent": true,
    "zone": "master"
    }
    | PING_TEMPLATE
  $dns_svc_template = @("DNS_TEMPLATE"/L)
    {
    "check_command": "dns",
    "object_name": "${dns_svc_template_name}",
    "object_type": "template",
    "vars": {
        "enable_pagerduty": "true"
    },
    "use_agent": true,
    "zone": "master"
    }
    | DNS_TEMPLATE
  $master_svc_template = @("MASTER_TEMPLATE"/L)
    {
    "check_command": "dhcp",
    "object_name": "${master_svc_template_name}",
    "object_type": "template",
    "vars": {
        "enable_pagerduty": "true"
    },
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
        "ldap_base": "dc=lsst,dc=cloud",
        "enable_pagerduty": "true"
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
        "disk_wfree": "20%",
        "enable_pagerduty": "true"
    },
    "zone": "master"
    }
    | DISK_TEMPLATE
  $ssh_svc_template = @("SSH_TEMPLATE"/L)
    {
    "check_command": "ssh",
    "object_name": "${ssh_svc_template_name}",
    "object_type": "template",
    "vars": {
        "enable_pagerduty": "true"
    },
    "use_agent": true,
    "zone": "master"
    }
    | SSH_TEMPLATE
  $tls_svc_template = @("TLS"/L)
    {
    "check_command": "http",
    "object_name": "${tls_svc_template_name}",
    "object_type": "template",
    "use_agent": false,
    "vars": {
        "http_certificate": "30",
        "enable_pagerduty": "true"
    },
    "zone": "master"
    }
    | TLS

  ## IMPORTANT
  ## The ntp_address must be change to an NTP Server,
  ## of our own once we have one operational on site
  $ntp_svc_template = @("NTP_TEMPLATE"/L)
    {
    "check_command": "ntp_time",
    "object_name": "${ntp_svc_template_name}",
    "object_type": "template",
    "use_agent": true,
    "vars": {
        "ntp_address": "ntp.shoa.cl",
        "enable_pagerduty": "true"
    },
    "zone": "master"
    }
    | NTP_TEMPLATE
  ## END OF NOTE

  ##Services Definition
  #Ping, disk, ssh and ntp skew monitoring
  $host_svc1 = @("HOST_SVC_1"/L)
    {
    "host": "${host_template}",
    "imports": [
        "${$ping_svc_template_name}"
    ],
    "object_name": "${host_svc_ping_name}",
    "vars": {
        "enable_pagerduty": "true"
    },
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
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | HOST_SVC_2
  $host_svc3 = @("HOST_SVC_3"/L)
    {
    "host": "${host_template}",
    "imports": [
        "${$ssh_svc_template_name}"
    ],
    "object_name": "${host_svc_ssh_name}",
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | HOST_SVC_3
  $host_svc4 = @("HOST_SVC_4"/L)
    {
    "host": "${host_template}",
    "imports": [
        "${$ntp_svc_template_name}"
    ],
    "object_name": "${host_svc_ntp_name}",
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | HOST_SVC_4
  #HTTP, Ping, disk, ssh and ntp skew monitoring
  $http_svc1 = @("HTTP_SVC_1"/L)
    {
    "host": "${http_template}",
    "imports": [
      "${$http_svc_template_name}"
    ],
    "object_name": "${http_svc_name}",
    "vars": {
        "enable_pagerduty": "true"
    },
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
    "vars": {
        "enable_pagerduty": "true"
    },
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
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | HTTP_SVC_3
  $http_svc4 = @("HTTP_SVC_4"/L)
    {
    "host": "${http_template}",
    "imports": [
        "${$ssh_svc_template_name}"
    ],
    "object_name": "${http_svc_ssh_name}",
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | HTTP_SVC_4
  $http_svc5 = @("HTTP_SVC_5"/L)
    {
    "host": "${http_template}",
    "imports": [
        "${$ntp_svc_template_name}"
    ],
    "object_name": "${http_svc_ntp_name}",
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | HTTP_SVC_5
  #DHCP, Ping, disk, ssh and ntp skew monitoring
  $master_svc1 = @("MASTER_SVC_1"/L)
    {
    "host": "${master_template}",
    "imports": [
      "${$master_svc_template_name}"
    ],
    "object_name": "${master_svc_dhcp_name}",
    "object_type": "object",
    "vars": {
      "dhcp_serverip": "${dhcp_server}",
      "enable_pagerduty": "true"
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
    "vars": {
        "enable_pagerduty": "true"
    },
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
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | MASTER_SVC_3
  $master_svc4 = @("MASTER_SVC_4"/L)
    {
    "host": "${master_template}",
    "imports": [
        "${$ssh_svc_template_name}"
    ],
    "object_name": "${master_svc_ssh_name}",
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | MASTER_SVC_4
  $master_svc5 = @("MASTER_SVC_5"/L)
    {
    "host": "${master_template}",
    "imports": [
        "${$ntp_svc_template_name}"
    ],
    "object_name": "${master_svc_ntp_name}",
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | MASTER_SVC_5
  $master_svc6 = @("MASTER_SVC_6"/L)
    {
    "host": "${master_template}",
    "imports": [
        "${$tls_svc_template_name}"
    ],
    "object_name": "${master_svc_tls_name}",
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | MASTER_SVC_6

  #DNS, Ping, disk, ssh and ntp skew monitoring
  $dns_svc1 = @("DNS_SVC_1"/L)
    {
    "host": "${dns_template}",
    "imports": [
      "${$dns_svc_template_name}"
    ],
    "object_name": "${dns_svc_name}",
    "vars": {
        "enable_pagerduty": "true"
    },
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
    "vars": {
        "enable_pagerduty": "true"
    },
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
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | DNS_SVC_3
  $dns_svc4 = @("DNS_SVC_4"/L)
    {
    "host": "${dns_template}",
    "imports": [
        "${$ssh_svc_template_name}"
    ],
    "object_name": "${dns_svc_ssh_name}",
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | DNS_SVC_4
  $dns_svc5 = @("DNS_SVC_5"/L)
    {
    "host": "${dns_template}",
    "imports": [
        "${$ntp_svc_template_name}"
    ],
    "object_name": "${dns_svc_ntp_name}",
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | DNS_SVC_5
  #LDAP, Ping, disk, ssh and ntp skew monitoring
  $ipa_svc1 = @("IPA_SVC_1"/L)
    {
    "host": "${ipa_template}",
    "imports": [
      "${$ipa_svc_template_name}"
    ],
    "object_name": "${ipa_svc_name}",
    "vars": {
        "enable_pagerduty": "true"
    },
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
    "vars": {
        "enable_pagerduty": "true"
    },
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
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | IPA_SVC_3
  $ipa_svc4 = @("IPA_SVC_4"/L)
    {
    "host": "${ipa_template}",
    "imports": [
        "${$ssh_svc_template_name}"
    ],
    "object_name": "${ipa_svc_ssh_name}",
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | IPA_SVC_4
  $ipa_svc5 = @("IPA_SVC_5"/L)
    {
    "host": "${ipa_template}",
    "imports": [
        "${$ntp_svc_template_name}"
    ],
    "object_name": "${ipa_svc_ntp_name}",
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | IPA_SVC_5

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
    },
    "zone": "master"
    }
    | MASTER_HOST

  ##Host Groups Definition
  $antu_template = @("ANTU"/L)
    {
    "assign_filter": "host.display_name=%22antu%2A%22",
    "display_name": "Antu Cluster",
    "object_name": "antu_cluster",
    "object_type": "object"
    }
    | ANTU
  $ruka_template = @("RUKA"/L)
    {
    "assign_filter": "host.display_name=%22ruka%2A%22",
    "display_name": "Ruka Cluster",
    "object_name": "ruka_cluster",
    "object_type": "object"
    }
    | RUKA
  $kueyen_template = @("KUEYEN"/L)
    {
    "assign_filter": "host.display_name=%22kueyen%2A%22",
    "display_name": "Kueyen Cluster",
    "object_name": "kueyen_cluster",
    "object_type": "object"
    }
    | KUEYEN
  $core_template = @("CORE"/L)
    {
    "assign_filter": "host.display_name=%22core%2A%22",
    "display_name": "Core Cluster",
    "object_name": "core_cluster",
    "object_type": "object"
    }
    | CORE
  $comcam_template = @("COMCAM"/L)
    {
    "assign_filter": "host.display_name=%22comcam%2A%22",
    "display_name": "ComCam Cluster",
    "object_name": "comcam_cluster",
    "object_type": "object"
    }
    | COMCAM
  $ls_nodes_template = @("NODES"/L)
    {
    "assign_filter": "host.display_name=%22ls-%2A%22",
    "display_name": "LS Nodes",
    "object_name": "ls_nodes",
    "object_type": "object"
    }
    | NODES
  $it_svc_template = @("IT"/L)
    {
    "assign_filter": "host.display_name=%22dns%2A%22|host.display_name=%22ipa%2A%22|host.display_name=%22foreman%2A%22",
    "display_name": "LS Nodes",
    "object_name": "ls_nodes",
    "object_type": "object"
    }
    | IT
  #<---------------------------End JSON Files --------------------------->
  #
  #
  #<-------------------Templates-Variables-Creation----------------------->
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

  $tls_svc_template_path = "${icinga_path}/${tls_svc_template_name}.json"
  $tls_svc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${tls_svc_template_name}' ${lt}"
  $tls_svc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$tls_svc_template_path}"

  $ssh_svc_template_path = "${icinga_path}/${ssh_svc_template_name}.json"
  $ssh_svc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ssh_svc_template_name}' ${lt}"
  $ssh_svc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$ssh_svc_template_path}"

  $ntp_svc_template_path = "${icinga_path}/${ntp_svc_template_name}.json"
  $ntp_svc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ntp_svc_template_name}' ${lt}"
  $ntp_svc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$ntp_svc_template_path}"

  #Services Creation
  $host_svc_path1 = "${icinga_path}/${host_svc_ping_name}.json"
  $host_svc_cond1 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${host_svc_ping_name}&host=${host_template}' ${lt}"
  $host_svc_cmd1  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${host_svc_path1}"
  $host_svc_path2 = "${icinga_path}/${host_svc_disk_name}.json"
  $host_svc_cond2 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${host_svc_disk_name}&host=${host_template}' ${lt}"
  $host_svc_cmd2  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${host_svc_path2}"
  $host_svc_path3 = "${icinga_path}/${host_svc_ssh_name}.json"
  $host_svc_cond3 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${host_svc_ssh_name}&host=${host_template}' ${lt}"
  $host_svc_cmd3  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${host_svc_path3}"
  $host_svc_path4 = "${icinga_path}/${host_svc_ntp_name}.json"
  $host_svc_cond4 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${host_svc_ntp_name}&host=${host_template}' ${lt}"
  $host_svc_cmd4  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${host_svc_path4}"

  $http_svc_path1 = "${icinga_path}/${http_svc_name}.json"
  $http_svc_cond1 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_name}&host=${http_template}' ${lt}"
  $http_svc_cmd1  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path1}"
  $http_svc_path2 = "${icinga_path}/${http_svc_ping_name}.json"
  $http_svc_cond2 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_ping_name}&host=${http_template}' ${lt}"
  $http_svc_cmd2  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path2}"
  $http_svc_path3 = "${icinga_path}/${http_svc_disk_name}.json"
  $http_svc_cond3 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_disk_name}&host=${http_template}' ${lt}"
  $http_svc_cmd3  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path3}"
  $http_svc_path4 = "${icinga_path}/${http_svc_ssh_name}.json"
  $http_svc_cond4 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_ssh_name}&host=${http_template}' ${lt}"
  $http_svc_cmd4  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path4}"
  $http_svc_path5 = "${icinga_path}/${http_svc_ntp_name}.json"
  $http_svc_cond5 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_ntp_name}&host=${http_template}' ${lt}"
  $http_svc_cmd5  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path5}"

  $dns_svc_path1  = "${icinga_path}/${dns_svc_name}.json"
  $dns_svc_cond1  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_name}&host=${dns_template}' ${lt}"
  $dns_svc_cmd1   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path1}"
  $dns_svc_path2  = "${icinga_path}/${dns_svc_ping_name}.json"
  $dns_svc_cond2  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_ping_name}&host=${dns_template}' ${lt}"
  $dns_svc_cmd2   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path2}"
  $dns_svc_path3  = "${icinga_path}/${dns_svc_disk_name}.json"
  $dns_svc_cond3  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_disk_name}&host=${dns_template}' ${lt}"
  $dns_svc_cmd3   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path3}"
  $dns_svc_path4  = "${icinga_path}/${dns_svc_ssh_name}.json"
  $dns_svc_cond4  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_ssh_name}&host=${dns_template}' ${lt}"
  $dns_svc_cmd4   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path4}"
  $dns_svc_path5  = "${icinga_path}/${dns_svc_ntp_name}.json"
  $dns_svc_cond5  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_ntp_name}&host=${dns_template}' ${lt}"
  $dns_svc_cmd5   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path5}"

  $master_svc_path1 = "${icinga_path}/${master_svc_dhcp_name}.json"
  $master_svc_cond1 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_dhcp_name}&host=${master_template}' ${lt}"
  $master_svc_cmd1  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path1}"
  $master_svc_path2 = "${icinga_path}/${master_svc_ping_name}.json"
  $master_svc_cond2 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_ping_name}&host=${master_template}' ${lt}"
  $master_svc_cmd2  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path2}"
  $master_svc_path3 = "${icinga_path}/${master_svc_disk_name}.json"
  $master_svc_cond3 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_disk_name}&host=${master_template}' ${lt}"
  $master_svc_cmd3  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path3}"
  $master_svc_path4 = "${icinga_path}/${master_svc_ssh_name}.json"
  $master_svc_cond4 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_ssh_name}&host=${master_template}' ${lt}"
  $master_svc_cmd4  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path4}"
  $master_svc_path5 = "${icinga_path}/${master_svc_ntp_name}.json"
  $master_svc_cond5 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_ntp_name}&host=${master_template}' ${lt}"
  $master_svc_cmd5  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path5}"
  $master_svc_path6 = "${icinga_path}/${master_svc_tls_name}.json"
  $master_svc_cond6 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_tls_name}&host=${master_template}' ${lt}"
  $master_svc_cmd6  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path6}"

  $ipa_svc_path1  = "${icinga_path}/${ipa_svc_name}.json"
  $ipa_svc_cond1  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_name}&host=${ipa_template}' ${lt}"
  $ipa_svc_cmd1   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${ipa_svc_path1}"
  $ipa_svc_path2  = "${icinga_path}/${ipa_svc_ping_name}.json"
  $ipa_svc_cond2  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_ping_name}&host=${ipa_template}' ${lt}"
  $ipa_svc_cmd2   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${ipa_svc_path2}"
  $ipa_svc_path3  = "${icinga_path}/${ipa_svc_disk_name}.json"
  $ipa_svc_cond3  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_disk_name}&host=${ipa_template}' ${lt}"
  $ipa_svc_cmd3   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${ipa_svc_path3}"
  $ipa_svc_path4  = "${icinga_path}/${ipa_svc_ssh_name}.json"
  $ipa_svc_cond4  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_ssh_name}&host=${ipa_template}' ${lt}"
  $ipa_svc_cmd4   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${ipa_svc_path4}"
  $ipa_svc_path5  = "${icinga_path}/${ipa_svc_ntp_name}.json"
  $ipa_svc_cond5  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_ntp_name}&host=${ipa_template}' ${lt}"
  $ipa_svc_cmd5   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${ipa_svc_path5}"

  #Host Groups Creation
  $antu_path = "${icinga_path}/${antu}.json"
  $antu_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_hostgroup}?name=${antu}' ${lt}"
  $antu_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_hostgroup}' -d @${antu_path}"

  $ruka_path = "${icinga_path}/${ruka}.json"
  $ruka_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_hostgroup}?name=${ruka}' ${lt}"
  $ruka_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_hostgroup}' -d @${ruka_path}"

  $kueyen_path = "${icinga_path}/${kueyen}.json"
  $kueyen_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_hostgroup}?name=${kueyen}' ${lt}"
  $kueyen_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_hostgroup}' -d @${kueyen_path}"

  $core_path = "${icinga_path}/${core}.json"
  $core_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_hostgroup}?name=${core}' ${lt}"
  $core_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_hostgroup}' -d @${core_path}"

  $comcam_path = "${icinga_path}/${comcam}.json"
  $comcam_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_hostgroup}?name=${comcam}' ${lt}"
  $comcam_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_hostgroup}' -d @${comcam_path}"

  $ls_path = "${icinga_path}/${ls_nodes}.json"
  $ls_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_hostgroup}?name=${ls_nodes}' ${lt}"
  $ls_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_hostgroup}' -d @${ls_path}"

  $it_path = "${icinga_path}/${it_svc}.json"
  $it_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_hostgroup}?name=${it_svc}' ${lt}"
  $it_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_hostgroup}' -d @${it_path}"

  #Master Host Creation
  $addhost_path = "${icinga_path}/${master_fqdn}.json"
  $addhost_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${master_fqdn}' ${lt}"
  $addhost_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${addhost_path}"
  #<---------------END-Templates-Variables-Creation----------------------->
  #
  #
  #<-------------------Files Creation and deployement--------------------->

  #Create a directory to allocate json files
  file { $icinga_path:
    ensure => 'directory',
  }
  #<---------------END-Files Creation and deployement--------------------->
  #
  #
  #<-----------------Repo-and-Packages-for-nwc_health--------------------->
  yumrepo { 'perl':
    ensure   => 'present',
    enabled  => true,
    descr    => 'Perl Modules (CentOS_7)',
    baseurl  => 'http://download.opensuse.org/repositories/home:/csbuild:/Perl/CentOS_7/',
    gpgcheck => true,
    gpgkey   => 'http://download.opensuse.org/repositories/home:/csbuild:/Perl/CentOS_7/repodata/repomd.xml.key',
    target   => '/etc/yum.repos.d/perl.repo',
  }
  #Packages Installation
  package { 'perl-Net-SNMP':
    ensure  => 'present',
    require => Yumrepo['perl'],
  }
  #<---------------------------Host-Templates----------------------------->
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
  #<-----------------------END-Host-Templates----------------------------->
  #
  #
  #<------------------------Service-Templates----------------------------->
  #Create http service template file
  file { $http_svc_template_path:
    ensure  => 'present',
    content => $http_svc_template,
    before  => Exec[$http_svc_template_cmd],
  }
  #Add http service template
  exec { $http_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_svc_template_cond,
    loglevel => debug,
  }
  #Create ping service template file
  file { $ping_svc_template_path:
    ensure  => 'present',
    content => $ping_svc_template,
    before  => Exec[$ping_svc_template_cmd],
  }
  #Add http service template
  exec { $ping_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ping_svc_template_cond,
    loglevel => debug,
  }
  #Create dhcp service template file
  file { $master_svc_template_path:
    ensure  => 'present',
    content => $master_svc_template,
    before  => Exec[$master_svc_template_cmd],
  }
  #Add http service template
  exec { $master_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_svc_template_cond,
    loglevel => debug,
  }
  #Create dns service template file 
  file { $dns_svc_template_path:
    ensure  => 'present',
    content => $dns_svc_template,
    before  => Exec[$dns_svc_template_cmd],
  }
  #Add dns service template
  exec { $dns_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_svc_template_cond,
    loglevel => debug,
  }
  #Create ipa service template file 
  file { $ipa_svc_template_path:
    ensure  => 'present',
    content => $ipa_svc_template,
    before  => Exec[$ipa_svc_template_cmd],
  }
  #Add ipa service template
  exec { $ipa_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ipa_svc_template_cond,
    loglevel => debug,
  }
  #Create disk service template file 
  file { $disk_svc_template_path:
    ensure  => 'present',
    content => $disk_svc_template,
    before  => Exec[$disk_svc_template_cmd],
  }
  #Add disk service template
  exec { $disk_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $disk_svc_template_cond,
    loglevel => debug,
  }
  #Create tls cert expiration service template file 
  file { $tls_svc_template_path:
    ensure  => 'present',
    content => $tls_svc_template,
    before  => Exec[$tls_svc_template_cmd],
  }
  #Add tls cert expiration service template
  exec { $tls_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $tls_svc_template_cond,
    loglevel => debug,
  }
  #Create ssh service template file 
  file { $ssh_svc_template_path:
    ensure  => 'present',
    content => $ssh_svc_template,
    before  => Exec[$ssh_svc_template_cmd],
  }
  #Add ssh service template
  exec { $ssh_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ssh_svc_template_cond,
    loglevel => debug,
  }
  #Create ntp skew service template file 
  file { $ntp_svc_template_path:
    ensure  => 'present',
    content => $ntp_svc_template,
    before  => Exec[$ntp_svc_template_cmd],
  }
  #Add ntp skew service template
  exec { $ntp_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ntp_svc_template_cond,
    loglevel => debug,
  }
  #<--------------------EMD-Service-Templates----------------------------->
  #
  #
  #<-----------------------Services-Definiton----------------------------->
  ##HostTemplate Services
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
  #Creates ssh resource file for HostTemplate and SshServiceTemplate
  file { $host_svc_path3:
    ensure  => 'present',
    content => $host_svc3,
    before  => Exec[$host_svc_cmd3],
  }
  #Adds ssh resource file for HostTemplate and SshServiceTemplate
  exec { $host_svc_cmd3:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $host_svc_cond3,
    loglevel => debug,
  }
  #Creates ntp skew resource file for HostTemplate and NtpServiceTemplate
  file { $host_svc_path4:
    ensure  => 'present',
    content => $host_svc4,
    before  => Exec[$host_svc_cmd4],
  }
  #Adds ntp skew resource file for HostTemplate and NtpServiceTemplate
  exec { $host_svc_cmd4:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $host_svc_cond4,
    loglevel => debug,
  }

  ##HttpTemplate Services
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
  #Creates ssh resource file for HttpTemplate and SshServiceTemplate
  file { $http_svc_path4:
    ensure  => 'present',
    content => $http_svc4,
    before  => Exec[$http_svc_cmd4],
  }
  #Adds ssh resource file for HttpTemplate and SshServiceTemplate
  exec { $http_svc_cmd4:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_svc_cond4,
    loglevel => debug,
  }
  #Creates ntp skew resource file for HttpTemplate and NtpServiceTemplate
  file { $http_svc_path5:
    ensure  => 'present',
    content => $http_svc5,
    before  => Exec[$http_svc_cmd5],
  }
  #Adds ntp skew resource file for HttpTemplate and NtpServiceTemplate
  exec { $http_svc_cmd5:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_svc_cond5,
    loglevel => debug,
  }

  ##DhcpTemplate Services
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
  #Creates ssh resource file for MasterTemplate and SshServiceTemplate
  file { $master_svc_path4:
    ensure  => 'present',
    content => $master_svc4,
    before  => Exec[$master_svc_cmd4],
  }
  #Adds ssh resource file for MasterTemplate and SshServiceTemplate
  exec { $master_svc_cmd4:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_svc_cond4,
    loglevel => debug,
  }
  #Creates ntp skew resource file for MasterTemplate and NtpServiceTemplate
  file { $master_svc_path5:
    ensure  => 'present',
    content => $master_svc5,
    before  => Exec[$master_svc_cmd5],
  }
  #Adds ntp skew resource file for MasterTemplate and NtpServiceTemplate
  exec { $master_svc_cmd5:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_svc_cond5,
    loglevel => debug,
  }
  #Creates tls cert expiration resource file for MasterTemplate and NtpServiceTemplate
  file { $master_svc_path6:
    ensure  => 'present',
    content => $master_svc6,
    before  => Exec[$master_svc_cmd6],
  }
  #Adds tls cert expiration file for MasterTemplate and NtpServiceTemplate
  exec { $master_svc_cmd6:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_svc_cond6,
    loglevel => debug,
  }

  ##DnsTemplate Services
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
  #Creates ssh resource file for DnsTemplate and SshServiceTemplate
  file { $dns_svc_path4:
    ensure  => 'present',
    content => $dns_svc4,
    before  => Exec[$dns_svc_cmd4],
  }
  #Adds ssh resource file for DnsTemplate and SshServiceTemplate
  exec { $dns_svc_cmd4:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_svc_cond4,
    loglevel => debug,
  }
  #Creates ntp skew resource file for DnsTemplate and NtpServiceTemplate
  file { $dns_svc_path5:
    ensure  => 'present',
    content => $dns_svc5,
    before  => Exec[$dns_svc_cmd5],
  }
  #Adds ntp skew resource file for DnsTemplate and NtpServiceTemplate
  exec { $dns_svc_cmd5:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_svc_cond5,
    loglevel => debug,
  }

  ##IpaTemplate Services
  #Creates ldap resource file for IpaTemplate and IpaServiceTemplate
  file { $ipa_svc_path1:
    ensure  => 'present',
    content => $ipa_svc1,
    before  => Exec[$ipa_svc_cmd1],
  }
  #Adds ldap resource file for IpaTemplate and IpaServiceTemplate
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
  #Creates ssh resource file for IpaTemplate and SshServiceTemplate
  file { $ipa_svc_path4:
    ensure  => 'present',
    content => $ipa_svc4,
    before  => Exec[$ipa_svc_cmd4],
  }
  #Adds ssh resource file for IpaTemplate and SshServiceTemplate
  exec { $ipa_svc_cmd4:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ipa_svc_cond4,
    loglevel => debug,
  }
  #Creates ntp skew resource file for IpaTemplate and NtpServiceTemplate
  file { $ipa_svc_path5:
    ensure  => 'present',
    content => $ipa_svc5,
    before  => Exec[$ipa_svc_cmd5],
  }
  #Adds ntp skew resource file for IpaTemplate and NtpServiceTemplate
  exec { $ipa_svc_cmd5:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ipa_svc_cond5,
    loglevel => debug,
  }
  #<-------------------END-Services-Definiton----------------------------->
  #
  #
  #<----------------------Host-Group-Definiton---------------------------->
  #Creates antu HostGroup File
  file { $antu_path:
    ensure  => 'present',
    content => $antu_template,
    before  => Exec[$antu_cmd],
  }
  #Adds antu Hostgroup
  exec { $antu_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $antu_cond,
    loglevel => debug,
  }
  #Creates ruka HostGroup File
  file { $ruka_path:
    ensure  => 'present',
    content => $ruka_template,
    before  => Exec[$ruka_cmd],
  }
  #Adds ruka Hostgroup
  exec { $ruka_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ruka_cond,
    loglevel => debug,
  }
  #Creates kueyen HostGroup File
  file { $kueyen_path:
    ensure  => 'present',
    content => $kueyen_template,
    before  => Exec[$kueyen_cmd],
  }
  #Adds kueyen Hostgroup
  exec { $kueyen_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $kueyen_cond,
    loglevel => debug,
  }
  #Creates comcam HostGroup File
  file { $comcam_path:
    ensure  => 'present',
    content => $comcam_template,
    before  => Exec[$comcam_cmd],
  }
  #Adds comcam Hostgroup
  exec { $comcam_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $comcam_cond,
    loglevel => debug,
  }
  #Creates core HostGroup File
  file { $core_path:
    ensure  => 'present',
    content => $core_template,
    before  => Exec[$core_cmd],
  }
  #Adds core Hostgroup
  exec { $core_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $core_cond,
    loglevel => debug,
  }
  #Creates LS Nodes HostGroup File
  file { $ls_path:
    ensure  => 'present',
    content => $ls_nodes_template,
    before  => Exec[$ls_cmd],
  }
  #Adds LS Nodes Hostgroup
  exec { $ls_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ls_cond,
    loglevel => debug,
  }
  #Creates IT Services HostGroup File
  file { $it_path:
    ensure  => 'present',
    content => $it_svc_template,
    before  => Exec[$it_cmd],
  }
  #Adds IT Services Hostgroup
  exec { $it_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $it_cond,
    loglevel => debug,
  }
  #<--------------------END-Host-Group-Definiton-------------------------->
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
  #check_nwc_health plugin
  $base_dir   = '/usr/lib64/nagios/plugins'
  $nwc_dir    = "${icinga_path}/check_nwc_health"
  $conditions = "--prefix=${nwc_dir} --with-nagios-user=root --with-nagios-group=icinga --with-perl=/bin/perl"
  vcsrepo { $nwc_dir:
    ensure   => present,
    provider => git,
    source   => 'https://github.com/lausser/check_nwc_health',
    revision => '1.4.9',
    require  => Class['::icingaweb2'],
  }
  ->exec {'git submodule update --init':
    cwd      => $nwc_dir,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    onlyif   => "test ! -f ${$nwc_dir}/plugins-scripts/check_nwc_health",
    loglevel => debug,
  }
  ->exec {"autoreconf;./configure ${conditions};make;make install;":
    cwd      => $nwc_dir,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => "test ! -f ${base_dir}/check_nwc_health",
    loglevel => debug,
  }
  ->file {"${base_dir}/check_nwc_health":
    ensure => 'present',
    source => "${$nwc_dir}/plugins-scripts/check_nwc_health",
    owner  => 'root', 
    group  => 'icinga',
    mode   => '4755',
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
  #<------------------END Files Creation and Deployement------------------>
}

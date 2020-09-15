# @summary
#   Define and create all file resources of icinga master

class profile::icinga::resources (
  String $credentials_hash,
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

  #Host Templates Names
  $host_template   = 'GeneralHostTemplate'
  $comcam_template = 'ComCamHostTemplate'
  $http_template   = 'HttpTemplate'
  $dns_template    = 'DnsTemplate'
  $master_template = 'MasterTemplate'
  $ipa_template    = 'IpaTemplate'
  $tls_template    = 'TlsTemplate'
  $dtn_template    = 'DtnTemplate'

  #Service Templates Names
  $http_svc_template_name   = 'HttpServiceTemplate'
  $ping_svc_template_name   = 'PingServiceTemplate'
  $dns_svc_template_name    = 'DnsServiceTemplate'
  $master_svc_template_name = 'MasterServiceTemplate'
  $ipa_svc_template_name    = 'IpaServiceTemplate'
  $disk_svc_template_name   = 'DiskServiceTemplate'
  $tls_svc_template_name    = 'TlsServiceTemplate'
  $ssh_svc_template_name    = 'SshServiceTemplate'
  $ntp_svc_template_name    = 'NtpServiceTemplate'
  $lhn_svc_template_name    = 'LhnServiceTemplate'

  #Service Names
  $host_svc_ping_name   = 'HostPingService'
  $host_svc_disk_name   = 'HostDiskService'
  $host_svc_ssh_name    = 'HostSshService'
  $host_svc_ntp_name    = 'HostNtpService'
  $comcam_svc_ping_name = 'ComcamPingService'
  $comcam_svc_disk_name = 'ComcamDiskService'
  $comcam_svc_ssh_name  = 'ComcamSshService'
  $comcam_svc_ntp_name  = 'ComcamNtpService'
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
  $dtn_svc_ping_name    = 'DtnPingService'
  $dtn_svc_disk_name    = 'DtnDiskService'
  $dtn_svc_ssh_name     = 'DtnSshService'
  $dtn_svc_lhn_name     = 'LHN_Link'

  #Hostgroups Names
  $antu     = 'antu_cluster'
  $ruka     = 'ruka_cluster'
  $kueyen   = 'kueyen_cluster'
  $core     = 'core_cluster'
  $comcam   = 'comcam_cluster'
  $ls_nodes = 'ls_nodes'
  $it_svc   = 'it_services'

  #Host Services Array
  $host_services = [
    "${host_template},${$ping_svc_template_name},${host_svc_ping_name}",
    "${host_template},${$disk_svc_template_name},${host_svc_disk_name}",
    "${host_template},${$ssh_svc_template_name},${host_svc_ssh_name}",
    "${host_template},${$ntp_svc_template_name},${host_svc_ntp_name}",
    "${comcam_template},${$ping_svc_template_name},${comcam_svc_ping_name}",
    "${comcam_template},${$disk_svc_template_name},${comcam_svc_disk_name}",
    "${comcam_template},${$ssh_svc_template_name},${comcam_svc_ssh_name}",
    "${comcam_template},${$ntp_svc_template_name},${comcam_svc_ntp_name}",
    "${http_template},${$http_svc_template_name},${http_svc_name}",
    "${http_template},${$ping_svc_template_name},${http_svc_ping_name}",
    "${http_template},${$disk_svc_template_name},${http_svc_disk_name}",
    "${http_template},${$ssh_svc_template_name},${http_svc_ssh_name}",
    "${http_template},${$ntp_svc_template_name},${http_svc_ntp_name}",
    "${master_template},${$tls_svc_template_name},${master_svc_tls_name}",
    "${master_template},${$ping_svc_template_name},${master_svc_ping_name}",
    "${master_template},${$disk_svc_template_name},${master_svc_disk_name}",
    "${master_template},${$ssh_svc_template_name},${master_svc_ssh_name}",
    "${master_template},${$ntp_svc_template_name},${master_svc_ntp_name}",
    "${dns_template},${$dns_svc_template_name},${dns_svc_name}",
    "${dns_template},${$ping_svc_template_name},${dns_svc_ping_name}",
    "${dns_template},${$disk_svc_template_name},${dns_svc_disk_name}",
    "${dns_template},${$ssh_svc_template_name},${dns_svc_ssh_name}",
    "${dns_template},${$ntp_svc_template_name},${dns_svc_ntp_name}",
    "${ipa_template},${$ipa_svc_template_name},${ipa_svc_name}",
    "${ipa_template},${$ping_svc_template_name},${ipa_svc_ping_name}",
    "${ipa_template},${$disk_svc_template_name},${ipa_svc_disk_name}",
    "${ipa_template},${$ssh_svc_template_name},${ipa_svc_ssh_name}",
    "${ipa_template},${$ntp_svc_template_name},${ipa_svc_ntp_name}",
    "${dtn_template},${$ping_svc_template_name},${dtn_svc_ping_name}",
    "${dtn_template},${$disk_svc_template_name},${dtn_svc_disk_name}",
    "${dtn_template},${$ssh_svc_template_name},${dtn_svc_ssh_name}",
    "${dtn_template},${$lhn_svc_template_name},${dtn_svc_lhn_name}",
  ]
  #Host Template Names Array
  $host_names = [
    $host_template,
    $comcam_template,
    $http_template,
    $master_template,
    $dns_template,
    $ipa_template,
    $dtn_template,
  ]
  #Service Templates Array
  $service_names = [
    "${http_svc_template_path};${http_svc_template};${http_svc_template_cmd};${http_svc_template_cond}",
    "${ping_svc_template_path};${ping_svc_template};${ping_svc_template_cmd};${ping_svc_template_cond}",
    "${master_svc_template_path};${master_svc_template};${master_svc_template_cmd};${master_svc_template_cond}",
    "${dns_svc_template_path};${dns_svc_template};${dns_svc_template_cmd};${dns_svc_template_cond}",
    "${ipa_svc_template_path};${ipa_svc_template};${ipa_svc_template_cmd};${ipa_svc_template_cond}",
    "${disk_svc_template_path};${disk_svc_template};${disk_svc_template_cmd};${disk_svc_template_cond}",
    "${tls_svc_template_path};${tls_svc_template};${tls_svc_template_cmd};${tls_svc_template_cond}",
    "${ssh_svc_template_path};${ssh_svc_template};${ssh_svc_template_cmd};${ssh_svc_template_cond}",
    "${ntp_svc_template_path};${ntp_svc_template};${ntp_svc_template_cmd};${ntp_svc_template_cond}",
    "${lhn_svc_template_path};${lhn_svc_template};${lhn_svc_template_cmd};${lhn_svc_template_cond}",
  ]
  #Host Groups Array
  $hostgroups_name = [
    "${antu},AntuCluster,antu_cluster,antu",
    "${ruka},RukaCluster,ruka_cluster,ruka",
    "${kueyen},KueyenCluster,kueyen_cluster,kueyen",
    "${core},CoreCluster,core_cluster,core",
    "${comcam},ComcamCluster,comcam_cluster,comcam",
    "${ls_nodes},LS_Nodes,ls_nodes,ls",
  ]
  #<--------End Variables Definition---------->
  #
  #
  #<---------------JSON Files ---------------->
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
  $ssh_svc_template = @("SSH_TEMPLATE"/L)
    {
    "check_command": "ssh",
    "object_name": "${ssh_svc_template_name}",
    "object_type": "template",
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
        "http_certificate": "30"
    },
    "zone": "master"
    }
    | TLS
  $lhn_svc_template = @("LHN"/L)
    {
    "check_command": "ping",
    "object_name": "${lhn_svc_template_name}",
    "object_type": "template",
    "use_agent": true,
    "vars": {
        "ping_address": "starlight-dtn.ncsa.illinois.edu",
        "ping_crta": "250",
        "ping_wrta": "225"
    },
    "zone": "master"
    }
    | LHN
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
        "ntp_address": "ntp.shoa.cl"
    },
    "zone": "master"
    }
    | NTP_TEMPLATE
  ## END OF NOTE

  ##Services Definition
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

  #Hostgroups JSON
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

  $lhn_svc_template_path = "${icinga_path}/${lhn_svc_template_name}.json"
  $lhn_svc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${lhn_svc_template_name}' ${lt}"
  $lhn_svc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$lhn_svc_template_path}"

  #Services Creation
  $master_svc_path1 = "${icinga_path}/${master_svc_dhcp_name}.json"
  $master_svc_cond1 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_dhcp_name}&host=${master_template}' ${lt}"
  $master_svc_cmd1  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path1}"

  #Host Groups Creation
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
  #<-------------END-Repo-and-Packages-for-nwc_health--------------------->
  #
  #
  #<----------------------Packages-for-check-link------------------------->
  archive {'/usr/lib64/nagios/plugins/check_netio':
    ensure => present,
    source => 'https://www.claudiokuenzler.com/monitoring-plugins/check_netio.sh',
  }
  ->file { '/usr/lib64/nagios/plugins/check_netio':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  #<------------------END-Packages-for-check-link------------------------->
  #
  #
  #<---------------------------Host-Templates----------------------------->
  $host_names.each |$host|{
    $host_path = "${$icinga_path}/${host}.json"
    $host_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${host}' ${lt}"
    $host_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${host_path}"

    #Create host template file
    file { $host_path:
      ensure  => 'present',
      content => @("GENERAL"/L)
        {
        "accept_config": true,
        "check_command": "hostalive",
        "has_agent": true,
        "master_should_connect": true,
        "max_check_attempts": "5",
        "object_name": "${host}",
        "object_type": "template"
        }
        | GENERAL
    }
    ->exec { $host_cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $host_cond,
      loglevel => debug,
    }
  }
  #Create tls cert expiration file
  file { $tls_template_path:
    ensure  => 'present',
    content => @("TLS"/L)
      {
      "accept_config": false,
      "check_command": "http",
      "has_agent": false,
      "master_should_connect": false,
      "max_check_attempts": "5",
      "vars": {
          "http_certificate": "30"
      },
      "object_name": "${tls_template}",
      "object_type": "template",
      }
      | TLS
  }
  ->exec { $tls_template_cmd:
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
  #Create Remote Ping service template file 
  file { $lhn_svc_template_path:
    ensure  => 'present',
    content => $lhn_svc_template,
    before  => Exec[$lhn_svc_template_cmd],
  }
  #Add Remote Ping service template
  exec { $lhn_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $lhn_svc_template_cond,
    loglevel => debug,
  }
  #<--------------------EMD-Service-Templates----------------------------->
  #
  #
  #<-----------------------Services-Definiton----------------------------->
  ##HostTemplate Services
  $host_services.each |$services|{
    $value = split($services,',')
    $svc_path  = "${icinga_path}/${value[2]}.json"
    $svc_cond  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${value[2]}&host=${value[0]}' ${lt}"
    $svc_cmd   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${svc_path}"

    file { $svc_path:
      ensure  => 'present',
      content => @("CONTENT"/L)
        {
        "host": "${value[0]}",
        "imports": [
            "${$value[1]}"
        ],
        "object_name": "${value[2]}",
        "object_type": "object"
        }
        | CONTENT
    }
    ->exec { $svc_cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $svc_cond,
      loglevel => debug,
    }
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

  #<-------------------END-Services-Definiton----------------------------->
  #
  #
  #<----------------------Host-Group-Definiton---------------------------->
  $hostgroups_name.each |$hostgroup|{
    $value = split($hostgroup,',')
    $hostgroup_path = "${icinga_path}/${$value[0]}.json"
    $hostgroup_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_hostgroup}?name=${value[0]}' ${lt}"
    $hostgroup_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_hostgroup}' -d @${hostgroup_path}"

    file { $hostgroup_path:
      ensure  => 'present',
      content => @("CLUSTER"/L)
        {
        "assign_filter": "host.display_name=%22${value[3]}%2A%22",
        "display_name": "${value[1]}",
        "object_name": "${value[2]}",
        "object_type": "object"
        }
        | CLUSTER
    }
    ->exec { $hostgroup_cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $hostgroup_cond,
      loglevel => debug,
    }
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

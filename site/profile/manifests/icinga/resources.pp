# @summary
#   Define and create all file resources of icinga master

class profile::icinga::resources (
  String $credentials_hash,
  String $site,
  String $dhcp_server,
) {
  #<----------Variables Definition------------>
  #Implicit usage of facts
  $master_fqdn  = $facts['networking']['fqdn']
  $master_ip  = $facts['networking']['ip']

  #Commands abreviation
  $url_deploy    = "https://${master_fqdn}/director/config/deploy"
  $url_host      = "https://${master_fqdn}/director/host"
  $url_svc       = "https://${master_fqdn}/director/service"
  $url_hostgroup = "https://${master_fqdn}/director/hostgroup"
  $url_svcgroup  = "https://${master_fqdn}/director/servicegroup"
  $credentials   = "Authorization:Basic ${credentials_hash}"
  $format        = 'Accept: application/json'
  $curl          = 'curl -s -k -H'
  $icinga_path   = '/opt/icinga'
  $lt            = '| grep Failed'

  #Host Templates Names
  $host_template      = 'GeneralHostTemplate'
  $comcam_template    = 'ComCamHostTemplate'
  $http_template      = 'HttpTemplate'
  $dns_template       = 'DnsTemplate'
  $master_template    = 'MasterTemplate'
  $ipa_template       = 'IpaTemplate'
  $tls_template       = 'TlsTemplate'
  $dtn_template       = 'DtnTemplate'
  $stayalive_template = 'OnlyPingTemplate'

  #Services Names
  $http_svc  = 'HttpService'
  $ping_svc  = 'PingService'
  $dns_svc   = 'DnsService'
  $dhcp_svc  = 'DhcpService'
  $ssh_svc   = 'SshService'
  $load_svc  = 'LoadService'
  $cpu_svc   = 'CpuService'
  $nic_svc   = 'NicService'
  $nic2_svc  = 'Nic2Service'
  $ntp_svc   = 'NtpService'
  $ldap_svc  = 'IpaService'
  $disk_svc  = 'DiskService'
  $proc_svc  = 'ProcessesService'
  $swap_svc  = 'SwapService'
  $user_svc  = 'UserService'
  $mem_svc   = 'RamService'
  $tls_svc   = 'TlsService'

  #Service Templates Names
  $http_svc_template_name   = "${http_svc}Template"
  $ping_svc_template_name   = "${ping_svc}Template"
  $dns_svc_template_name    = "${dns_svc}Template"
  $master_svc_template_name = 'MasterServiceTemplate'
  $ssh_svc_template_name    = "${ssh_svc}Template"
  $tls_svc_template_name    = "${tls_svc}Template"
  $ntp_svc_template_name    = "${ntp_svc}Template"
  $lhn_svc_template_name    = 'LhnServiceTemplate'
  $ipa_svc_template_name    = "${ldap_svc}Template"
  $disk_svc_template_name   = "${disk_svc}Template"
  $load_svc_template_name   = "${load_svc}Template"
  $swap_svc_template_name   = "${swap_svc}Template"
  $ram_svc_template_name    = "${mem_svc}Template"
  $proc_svc_template_name   = "${proc_svc}Template"
  $user_svc_template_name   = "${user_svc}Template"
  $cpu_svc_template_name    = "${cpu_svc}Template"
  $nic_svc_template_name    = "${nic_svc}Template"
  $nic2_svc_template_name   = "${nic2_svc}Template"

  #Service Names
  $host_svc_ping_name   = "Host${ping_svc}"
  $host_svc_disk_name   = "Host${disk_svc}"
  $host_svc_ssh_name    = "Host${ssh_svc}"
  $host_svc_ntp_name    = "Host${ntp_svc}"
  $host_svc_nic2_name   = "Host${nic2_svc}"
  $comcam_svc_ping_name = "Comcam${ping_svc}"
  $comcam_svc_disk_name = "Comcam${disk_svc}"
  $comcam_svc_ssh_name  = "Comcam${ssh_svc}"
  $comcam_svc_ntp_name  = "Comcam${ntp_svc}"
  $comcam_svc_load_name = "Comcam${load_svc}"
  $comcam_svc_swap_name = "Comcam${swap_svc}"
  $comcam_svc_ram_name  = "Comcam${mem_svc}"
  $comcam_svc_proc_name = "Comcam${proc_svc}"
  $comcam_svc_user_name = "Comcam${user_svc}"
  $comcam_svc_cpu_name  = "Comcam${cpu_svc}"
  $comcam_svc_nic_name  = "Comcam${nic_svc}"
  $comcam_svc_nic2_name = "Comcam${nic2_svc}"
  $dns_svc_name         = $dns_svc
  $dns_svc_ping_name    = "Dns${ping_svc}"
  $dns_svc_disk_name    = "Dns${disk_svc}"
  $dns_svc_ssh_name     = "Dns${ssh_svc}"
  $dns_svc_ntp_name     = "Dns${ntp_svc}"
  $master_svc_dhcp_name = "Master${dhcp_svc}"
  $master_svc_ping_name = "Master${ping_svc}"
  $master_svc_disk_name = "Master${disk_svc}"
  $master_svc_tls_name  = "Master${tls_svc}"
  $master_svc_ssh_name  = "Master${ssh_svc}"
  $master_svc_ntp_name  = "Master${ntp_svc}"
  $master_svc_cpu_name  = "Master${cpu_svc}"
  $http_svc_name        = $http_svc
  $http_svc_ping_name   = "Http${ping_svc}"
  $http_svc_disk_name   = "Http${disk_svc}"
  $http_svc_ssh_name    = "Http${ssh_svc}"
  $http_svc_ntp_name    = "Http${ntp_svc}"
  $ipa_svc_name         = $ldap_svc
  $ipa_svc_ping_name    = "Ipa${ping_svc}"
  $ipa_svc_disk_name    = "Ipa${disk_svc}"
  $ipa_svc_ssh_name     = "Ipa${ssh_svc}"
  $ipa_svc_ntp_name     = "Ipa${ntp_svc}"
  $dtn_svc_ping_name    = "Dtn${ping_svc}"
  $dtn_svc_disk_name    = "Dtn${disk_svc}"
  $dtn_svc_ssh_name     = "Dtn${ssh_svc}"
  $dtn_svc_lhn_name     = 'LHN_Link'

  #Hostgroups Names
  $yagan    = 'yagan_cluster'
  $antu     = 'antu_cluster'
  $ruka     = 'ruka_cluster'
  $kueyen   = 'kueyen_cluster'
  $core     = 'core_cluster'
  $comcam   = 'comcam_cluster'
  $ls_nodes = 'ls_nodes'
  $it_svc   = 'it_services'
  $bdc      = 'bdc_servers'

  #Service Templates Array
  $service_template = [
    "http,${http_svc_template_name},0",
    "hostalive,${ping_svc_template_name},0",
    "dns,${dns_svc_template_name},0",
    "dhcp,${master_svc_template_name},0",
    "ssh,${ssh_svc_template_name},0",
    "load,${load_svc_template_name},0",
    "cpu,${cpu_svc_template_name},0",
    "netio,${nic_svc_template_name},0",
    "netio2,${nic2_svc_template_name},0",
    "http,${tls_svc_template_name},1,http_certificate,30",
    "ntp_time,${ntp_svc_template_name},1,ntp_address,ntp.shoa.cl",
    "ldap,${ipa_svc_template_name},2",
    "disk,${disk_svc_template_name},3,disk_cfree,3%,disk_wfree,6%",
    "procs,${proc_svc_template_name},3,procs_warning,650,procs_critical,700",
    "swap,${swap_svc_template_name},3,users_cgreater,50,users_wgreater,40",
    "users,${user_svc_template_name},3,users_cgreater,50,users_wgreater,40",
    "ping,${lhn_svc_template_name},4,ping_address,starlight-dtn.ncsa.illinois.edu,ping_crta,250,ping_wrta,225",
    "mem,${ram_svc_template_name},4,mem_free,true,mem_warning,0.05,mem_critical,0.01",
  ]
  #Host Services Array
  $host_services = [
    "${host_template},${$ping_svc_template_name},${host_svc_ping_name}",
    "${host_template},${$disk_svc_template_name},${host_svc_disk_name}",
    "${host_template},${$ssh_svc_template_name},${host_svc_ssh_name}",
    "${host_template},${$ntp_svc_template_name},${host_svc_ntp_name}",
    "net-dx.cp.lsst.org,${$nic2_svc_template_name},${host_svc_nic2_name}",
    "${comcam_template},${$ping_svc_template_name},${comcam_svc_ping_name}",
    "${comcam_template},${$disk_svc_template_name},${comcam_svc_disk_name}",
    "${comcam_template},${$ssh_svc_template_name},${comcam_svc_ssh_name}",
    "${comcam_template},${$ntp_svc_template_name},${comcam_svc_ntp_name}",
    "${comcam_template},${$load_svc_template_name},${comcam_svc_load_name}",
    "${comcam_template},${$swap_svc_template_name},${comcam_svc_swap_name}",
    "${comcam_template},${$ram_svc_template_name},${comcam_svc_ram_name}",
    "${comcam_template},${$proc_svc_template_name},${comcam_svc_proc_name}",
    "${comcam_template},${$user_svc_template_name},${comcam_svc_user_name}",
    "${comcam_template},${$cpu_svc_template_name},${comcam_svc_cpu_name}",
    "${comcam_template},${$nic_svc_template_name},${comcam_svc_nic_name}",
    "comcam-fp01.cp.lsst.org,${$nic2_svc_template_name},${comcam_svc_nic2_name}",
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
    "${master_template},${$cpu_svc_template_name},${master_svc_cpu_name}",
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
    "${host_template},0",
    "${comcam_template},0",
    "${http_template},0",
    "${master_template},0",
    "${dns_template},0",
    "${ipa_template},0",
    "${dtn_template},0",
    "${stayalive_template},0",
    "${tls_template},1",
  ]
  #Host Groups Array, ESXi Hosts and nodes
  if $site == 'base' {
    $hostgroups_name = [
      "${antu},AntuCluster,antu_cluster,host.display_name=%22antu%2A%22",
      "${ruka},RukaCluster,ruka_cluster,host.display_name=%22ruka%2A%22",
      "${kueyen},KueyenCluster,kueyen_cluster,host.display_name=%22kueyen%2A%22",
      "${core},CoreCluster,core_cluster,host.display_name=%22core%2A%22",
      "${comcam},ComcamCluster,comcam_cluster,host.display_name=%22comcam%2A%22",
      "${ls_nodes},LS_Nodes,ls_nodes,ls",
      "${it_svc},IT-Services,it_services,host.display_name=%22dns%2A%22|host.display_name=%22ipa%2A%22|host.display_name=%22foreman%2A%22",
      "${bdc},BDC-Servers,bdc_servers,!(host.display_name=%22bdc%2A%22|host.display_name=%22Vlan%2A%22|host.display_name=%22nob%2A%22|host.display_name=%22rubinobs%2A%22)",
    ]
    $nodes_list  = [
      'vsphere04.ls.lsst.org,139.229.135.37',
      'vsphere05.ls.lsst.org,139.229.135.38',
      'vsphere06.ls.lsst.org,139.229.135.39',
      'vcenter.cp.lsst.org,139.229.160.60',
      'icinga-master.cp.lsst.org,139.229.160.31'
    ]
  }
  elsif $site == 'summit' {
    $hostgroups_name = [
      "${yagan},YaganCluster,yagan_cluster,host.display_name=%22yagan%2A%22",
      "${core},CoreCluster,core_cluster,host.display_name=%22core%2A%22",
      "${comcam},ComcamCluster,comcam_cluster,host.display_name=%22comcam%2A%22",
      "${it_svc},IT-Services,it_services,host.display_name=%22dns%2A%22|host.display_name=%22ipa%2A%22|host.display_name=%22foreman%2A%22",
    ]
    $nodes_list  = [
      'vsphere01.cp.lsst.org,139.229.160.57',
      'vsphere02.cp.lsst.org,139.229.160.58',
      'vsphere03.cp.lsst.org,139.229.160.59',
      'vcenter.cp.lsst.org,139.229.160.60',
      'icinga-master.ls.lsst.org,139.229.135.31'
    ]
  }

  #Service Groups Array
  $servicegroup_name = [
    "${http_svc},${http_svc}Group",
    "${ping_svc},${ping_svc}Group",
    "${dhcp_svc},${dhcp_svc}Group",
    "${ssh_svc},${ssh_svc}Group",
    "${load_svc},${load_svc}Group",
    "${cpu_svc},${cpu_svc}Group",
    "${nic_svc},${nic_svc}Group",
    "${ntp_svc},${ntp_svc}Group",
    "${ldap_svc},${ldap_svc}Group",
    "${disk_svc},${disk_svc}Group",
    "${proc_svc},${proc_svc}Group",
    "${swap_svc},${swap_svc}Group",
    "${user_svc},${user_svc}Group",
    "${mem_svc},${mem_svc}Group",
  ]
  #<-------------------End Variables Definition--------------------------->
  #
  #
  #<-------------------Templates-Variables-Creation----------------------->
  #Services Creation
  $master_svc_path1 = "${icinga_path}/${master_svc_dhcp_name}.json"
  $master_svc_cond1 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_dhcp_name}&host=${master_template}' ${lt}"
  $master_svc_cmd1  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path1}"

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
  #<-------------------------Packages Installation------------------------>
  #Packages Installation
  package { 'perl-Net-SNMP':
    ensure  => 'present'
  }
  #<----------------------END-Packages Installation----------------------->
  #
  #
  #<---------------------------Host-Templates----------------------------->
  $host_names.each |$host| {
    $value = split($host,',')
    $host_path = "${$icinga_path}/${value[0]}.json"
    $host_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${value[0]}' ${lt}"
    $host_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${host_path}"
    if ($value[1]=='1') {
      $content = @("TLS"/L)
        {
        "accept_config": false,
        "check_command": "http",
        "has_agent": false,
        "master_should_connect": false,
        "max_check_attempts": "5",
        "vars": {
            "http_certificate": "30"
        },
        "object_name": "${value[0]}",
        "object_type": "template"
        }
        | TLS
    }
    else {
      $content = @("HOST_TEMPLATE"/L)
        {
        "accept_config": true,
        "check_command": "hostalive",
        "has_agent": true,
        "master_should_connect": true,
        "max_check_attempts": "5",
        "object_name": "${value[0]}",
        "object_type": "template"
        }
        | HOST_TEMPLATE
    }
    #Create host template file
    file { $host_path:
      ensure  => 'present',
      content => $content
    }
    ->exec { $host_cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $host_cond,
      loglevel => debug,
    }
  }
  #<-----------------------END-Host-Templates----------------------------->
  #
  #
  #<------------------------Service-Templates----------------------------->
  $service_template.each |$stemplate| {
    $value = split($stemplate, ',')
    $svc_template_path = "${icinga_path}/${value[1]}.json"
    $svc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${value[1]}' ${lt}"
    $svc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${svc_template_path}"
    if ($value[2]=='0') {
      $content = @("TEMPLATE"/L)
        {
        "check_command": "${value[0]}",
        "object_name": "${value[1]}",
        "object_type": "template",
        "use_agent": true,
        "zone": "master"
        }
        | TEMPLATE
    }
    elsif ($value[2]=='1') {
      $content = @("TEMPLATE1"/L)
        {
        "check_command": "${value[0]}",
        "object_name": "${value[1]}",
        "object_type": "template",
        "use_agent": true,
        "vars": {
          "${value[3]}": "${value[4]}"
        },
        "zone": "master"
        }
        | TEMPLATE1
    }
    elsif ($value[2]=='2') {
      $content = @("TEMPLATE2"/L)
        {
        "check_command": "${value[0]}",
        "object_name": "${value[1]}",
        "object_type": "template",
        "use_agent": true,
        "vars": {
            "ldap_address": "localhost",
            "ldap_base": "dc=lsst,dc=cloud"
        },
        "zone": "master"
        }
        | TEMPLATE2
    }
    elsif ($value[2]=='3') {
      $content = @("TEMPLATE3"/L)
        {
        "check_command": "${value[0]}",
        "object_name": "${value[1]}",
        "object_type": "template",
        "use_agent": true,
        "vars": {
            "${value[3]}": "${value[4]}",
            "${value[5]}": "${value[6]}"
        },
        "zone": "master"
        }
        | TEMPLATE3
    }
    elsif ($value[2]=='4') {
      $content = @("TEMPLATE4"/L)
        {
        "check_command": "${value[0]}",
        "object_name": "${value[1]}",
        "object_type": "template",
        "use_agent": true,
        "vars": {
            "${value[3]}": "${value[4]}",
            "${value[5]}": "${value[6]}",
            "${value[7]}": "${value[8]}"
        },
        "zone": "master"
        }
        | TEMPLATE4
    }
    else {
      notice("No content has beeing assigned to ${value[1]}")
    }
    file { $svc_template_path:
      ensure  => 'present',
      content => $content
    }
    ->exec { $svc_template_cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $svc_template_cond,
      loglevel => debug,
    }
  }
  #<--------------------EMD-Service-Templates----------------------------->
  #
  #
  #<-----------------------Services-Definiton----------------------------->
  ##HostTemplate Services
  $host_services.each |$services| {
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
    content => @("MASTER_SVC_1"/L)
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
  }
  ->exec { $master_svc_cmd1:
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
  $hostgroups_name.each |$hostgroup| {
    $value = split($hostgroup,',')
    $hostgroup_path = "${icinga_path}/${$value[0]}.json"
    $hostgroup_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_hostgroup}?name=${value[0]}' ${lt}"
    $hostgroup_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_hostgroup}' -d @${hostgroup_path}"

    file { $hostgroup_path:
      ensure  => 'present',
      content => @("CLUSTER"/L)
        {
        "assign_filter": "${value[3]}",
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
  #<-----------------------END-Host-Group-Definiton----------------------->
  #
  #
  #<------------------------Service-Group-Definiton----------------------->
  $servicegroup_name.each |$svcgroup| {
    $value = split($svcgroup,',')
    $svcgroup_path = "${icinga_path}/${$value[1]}.json"
    $svcgroup_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svcgroup}?name=${value[1]}' ${lt}"
    $svcgroup_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svcgroup}' -d @${svcgroup_path}"

    file { $svcgroup_path:
      ensure  => 'present',
      content => @("GROUP"/L)
        {
        "assign_filter": "service.name=%22%2A${value[0]}%22",
        "display_name": "${value[1]}",
        "object_name": "${value[1]}",
        "object_type": "object"

        }
        | GROUP
    }
    ->exec { $svcgroup_cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $svcgroup_cond,
      loglevel => debug,
    }
  }
  #<--------------------END-Service-Group-Definiton----------------------->
  #
  #
  #<--------------------Files Creation and Deployement-------------------->
  #  Master Host
  file { $addhost_path:
    ensure  => 'present',
    content => @("MASTER_HOST"/L)
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
  }
  -> exec { $addhost_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $addhost_cond,
    loglevel => debug,
  }
  #  Schedule Deployment
  exec { "${curl} '${credentials}' -H '${format}' -X POST '${url_deploy}'":
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    loglevel => debug,
  }

  #  ESXi Hosts and Cross Site Check
  $nodes_list.each |$host| {
    $value = split($host,',')
    $path = "${icinga_path}/${value[0]}.json"
    $cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${value[0]}' ${lt}"
    $cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${path}"

    file { $path:
      ensure  => 'present',
      content => @("HOST_CONTENT"/L)
        {
        "address": "${value[1]}",
        "display_name": "${value[0]}",
        "imports": [
          "${stayalive_template}"
        ],
        "object_name":"${value[0]}",
        "object_type": "object",
        "vars": {
            "safed_profile": "3"
        },
        "zone": "master"
        }
        | HOST_CONTENT
    }
    ->exec { $cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $cond,
      loglevel => debug,
    }
  }
  #<------------------END Files Creation and Deployement------------------>
}

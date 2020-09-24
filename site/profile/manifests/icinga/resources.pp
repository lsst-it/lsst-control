# @summary
#   Define and create all file resources of icinga master

class profile::icinga::resources (
  String $credentials_hash,
  String $dhcp_server,
){
  #<----------Variables Definition------------>
  #Implicit usage of facts
  $master_fqdn  = $facts['networking']['fqdn']
  $master_ip  = $facts['networking']['ip']

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
  $ssh_svc_template_name    = 'SshServiceTemplate'
  $tls_svc_template_name    = 'TlsServiceTemplate'
  $ntp_svc_template_name    = 'NtpServiceTemplate'
  $lhn_svc_template_name    = 'LhnServiceTemplate'
  $ipa_svc_template_name    = 'IpaServiceTemplate'
  $disk_svc_template_name   = 'DiskServiceTemplate'
  $cpu_svc_template_name    = 'CpuServiceTemplate'
  $swap_svc_template_name   = 'SwapServiceTemplate'
  $ram_svc_template_name    = 'RamServiceTemplate'

  #Service Names
  $host_svc_ping_name   = 'HostPingService'
  $host_svc_disk_name   = 'HostDiskService'
  $host_svc_ssh_name    = 'HostSshService'
  $host_svc_ntp_name    = 'HostNtpService'
  $comcam_svc_ping_name = 'ComcamPingService'
  $comcam_svc_disk_name = 'ComcamDiskService'
  $comcam_svc_ssh_name  = 'ComcamSshService'
  $comcam_svc_ntp_name  = 'ComcamNtpService'
  $comcam_svc_cpu_name  = 'ComcamCpuService'
  $comcam_svc_swap_name = 'ComcamSwapService'
  $comcam_svc_ram_name  = 'ComcamRamService'
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

  #Service Templates Array
  $service_template = [
    "http,${http_svc_template_name},0",
    "hostalive,${ping_svc_template_name},0",
    "dns,${dns_svc_template_name},0",
    "dhcp,${master_svc_template_name},0",
    "ssh,${ssh_svc_template_name},0",
    "load,${cpu_svc_template_name},0",
    "http,${tls_svc_template_name},1,http_certificate,30",
    "ntp_time,${ntp_svc_template_name},1,ntp_address,ntp.shoa.cl",
    "ldap,${ipa_svc_template_name},2",
    "disk,${disk_svc_template_name},3",
    "ping,${lhn_svc_template_name},4,ping_address,starlight-dtn.ncsa.illinois.edu,ping_crta,250,ping_wrta,225",
    "mem,${ram_svc_template_name},4,mem_free,true,mem_warning,0.05,mem_critical,0.01",
    "swap,${swap_svc_template_name},5,swap_cfree,15,swap_wfree,25",
  ]
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
    "${comcam_template},${$cpu_svc_template_name},${comcam_svc_cpu_name}",
    "${comcam_template},${$swap_svc_template_name},${comcam_svc_swap_name}",
    "${comcam_template},${$ram_svc_template_name},${comcam_svc_ram_name}",
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
    "${host_template},0",
    "${comcam_template},0",
    "${http_template},0",
    "${master_template},0",
    "${dns_template},0",
    "${ipa_template},0",
    "${dtn_template},0",
    "${tls_template},1",
  ]
  #Host Groups Array
  $hostgroups_name = [
    "${antu},AntuCluster,antu_cluster,host.display_name=%22antu%2A%22",
    "${ruka},RukaCluster,ruka_cluster,host.display_name=%22ruka%2A%22",
    "${kueyen},KueyenCluster,kueyen_cluster,host.display_name=%22kueyen%2A%22",
    "${core},CoreCluster,core_cluster,host.display_name=%22core%2A%22",
    "${comcam},ComcamCluster,comcam_cluster,host.display_name=%22comcam%2A%22",
    "${ls_nodes},LS_Nodes,ls_nodes,ls",
    "${it_svc},IT-Services,it_services,host.display_name=%22dns%2A%22|host.display_name=%22ipa%2A%22|host.display_name=%22foreman%2A%22",
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
  #<-----------------Packages and Plugins Installation-------------------->
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
  #Check memory plugin
  archive {'/usr/lib64/nagios/plugins/check_mem':
    ensure => present,
    source => 'https://raw.githubusercontent.com/justintime/nagios-plugins/master/check_mem/check_mem.pl',
  }
  ->file { '/usr/lib64/nagios/plugins/check_mem':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  #<-------------END-Packages and Plugins Installation-------------------->
  #
  #
  #<---------------------------Host-Templates----------------------------->
  $host_names.each |$host|{
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
  $service_template.each |$stemplate|{
    $value = split($stemplate, ',')
    $svc_template_path = "${icinga_path}/${value[1]}.json"
    $svc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${value[1]}' ${lt}"
    $svc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${svc_template_path}"
    if ($value[2]=='0'){
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
    elsif ($value[2]=='1'){
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
    elsif ($value[2]=='2'){
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
    elsif ($value[2]=='3'){
      $content = @("TEMPLATE3"/L)
        {
        "check_command": "${value[0]}",
        "object_name": "${value[1]}",
        "object_type": "template",
        "use_agent": true,
        "vars": {
            "disk_cfree": "10%",
            "disk_wfree": "20%"
        },
        "zone": "master"
        }
        | TEMPLATE3
    }
    elsif ($value[2]=='4'){
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
    elsif ($value[2]=='5'){
      $content = @("TEMPLATE5"/L)
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
        | TEMPLATE5
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
  $hostgroups_name.each |$hostgroup|{
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
  #<--------------------END-Host-Group-Definiton-------------------------->
  #
  #
  #<----------------------Plugins-Configuration--------------------------->
  #Change permissions to dhcp and disk plugins
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
  ##Check NIC Link 
  archive {'/usr/lib64/nagios/plugins/check_netio':
    ensure => present,
    source => 'https://www.claudiokuenzler.com/monitoring-plugins/check_netio.sh',
  }
  ->file { '/usr/lib64/nagios/plugins/check_netio':
    owner => 'root',
    group => 'icinga',
    mode  => '4755',
  }
  #<--------------------END-Plugins-Configuration------------------------->
  #
  #
  #<----------------------Plugins-Configuration--------------------------->
  ##Add Master Host
  #Create master host file
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
  ->exec { $addhost_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $addhost_cond,
    loglevel => debug,
  }
  #<------------------END Files Creation and Deployement------------------>
}

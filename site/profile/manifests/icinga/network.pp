# @summary
#   Define and create icinga objects for network monitoring

class profile::icinga::network (
  String $site,
  String $credentials_hash,
) {
  #<-------------------------Variables Definition------------------------->
  #Implicit usage of facts
  $master_fqdn  = $facts['networking']['fqdn']

  #Names Definition
  $nwc_name                   = 'nwc_health'
  $nwc_notification_name      = 'nwc-template'
  $network_host_template_name = 'NetworkHostTemplate'
  $gateway_host_template_name = 'GatewayInterfacesTemplate'
  $network_hostgroup_name     = 'NetworkDevices'
  $gateway_hostgroup_name     = 'GatewayInterfaces'

  $intstat_svc_template_name  = 'InterfaceStatusServiceTemplate'
  $interror_svc_template_name = 'InterfaceErrorsServiceTemplate'
  $env_svc_template_name      = 'EnvironmentServiceTemplate'

  $network_svc_intstat_name   = 'NetworkInterfaceStatusService'
  $network_svc_interror_name  = 'NetworkInterfaceErrorsService'
  $network_svc_env_name       = 'NetworkEnvironmentalService'

  #Hosts Name Array
  $community   = 'rubinobs'
  if $site == 'base' {
    $host_list  = [
      'nob1-as01.ls.lsst.org,10.49.0.11',
      'nob1-as02.ls.lsst.org,10.49.0.12',
      'nob1-as03.ls.lsst.org,10.49.0.13',
      'nob1-as04.ls.lsst.org,10.49.0.14',
      'nob2-as01.ls.lsst.org,10.49.0.21',
      'nob2-as02.ls.lsst.org,10.49.0.22',
      'nob2-as03.ls.lsst.org,10.49.0.23',
      'nob2-as04.ls.lsst.org,10.49.0.24',
      'bdc-is03.ls.lsst.org,10.49.0.27',
      'bdc-is06.ls.lsst.org,10.49.0.30',
      'bdc-is09.ls.lsst.org,10.49.0.33',
      'bdc-is10.ls.lsst.org,10.49.0.34',
      'bdc-is13.ls.lsst.org,10.49.0.37',
      'bdc-is14.ls.lsst.org,10.49.0.38',
      'bdc-as01.ls.lsst.org,10.49.0.91',
      'bdc-as02.ls.lsst.org,10.49.0.92',
      'prep-room01.ls.lsst.org,10.49.0.99',
      'bdc-ds01.ls.lsst.org,10.49.0.254',
      'bdc-cr01.ls.lsst.org,10.48.1.1',
      'bdc-cr02.ls.lsst.org,10.48.1.2',
      'rubinobs-br01.ls.lsst.org,10.48.1.4',
      'rubinobs-br02.ls.lsst.org,10.48.1.5',
      'cube.ls.lsst.org,139.229.134.1',
    ]
    $gw_list  = [
      'Vlan2100_IT-General-Services,10.49.0.254',
      'Vlan900_LSST-Transit-LAN,192.168.255.4',
      'Vlan2100_IT-Management_,10.49.0.254',
      'Vlan2101_IT-General-Services,139.229.134.254',
      'Vlan2102_IT-GS-Servers_,139.229.135.254',
      'Vlan2113_LSST-Trusted-Contractors,139.229.158.190',
      'Vlan2114_LSST-AURA,139.229.158.254',
      'Vlan2115_LSST-Untrusted-Contractors,139.229.159.126',
      'Vlan2116_LSST-Guests,139.229.159.254',
      'Vlan2121_LSST-VoIP,10.49.1.254',
      'Vlan2123_LSST-AP,10.49.3.254',
      'Vlan2125_LSST-Printers,10.49.5.254',
      'Vlan2200_CDS-CC,139.229.149.254',
      'Vlan2300_OCS-CC,139.229.144.126',
      'Vlan2400_CDS-ARCH,139.229.147.254',
      'Vlan2401_CDS-CC-PXE,139.229.146.254',
      'Vlan2402_CDS-NAS,139.229.148.254',
      'Vlan2500_CCS,139.229.150.126',
      'Vlan2903_IT-IPMI-SRV,10.50.3.254',
      'Vlan300_LHN-Primary-Protected,198.32.252.233',
      'Vlan301_LHN-Primary-Express,198.32.252.235',
      'Vlan302_LHN-BackUP-Protected,198.32.252.225',
      'Vlan304_LHN-BackUP-Express,198.32.252.227',
      'Vlan330_LHN-DTN01,139.229.140.130',
      'Vlan340_LHN-DTN02,139.229.140.132',
      'Vlan360_Perfsonar1-1,139.229.140.134',
      'Vlan370_Perfsonar1-2,139.229.140.136',
      'bdc-wlc.ls.lsst.org,139.229.134.100'
    ]
  }
  elsif $site == 'summit' {
    $host_list  = [
      'comp-cr01.cp.lsst.org,10.16.1.1',
      'comp-cr02.cp.lsst.org,10.16.1.2',
      'main1-as01.cp.lsst.org,10.17.0.1',
      'villa-as01.cp.lsst.org,10.17.0.100',
      'casino-as01.cp.lsst.org,10.17.0.101',
      'penon-as01.cp.lsst.org,10.17.0.102',
      'eie-as01.cp.lsst.org,10.17.0.103',
      'mill-as01.cp.lsst.org,10.17.0.104',
      'aux-as01.cp.lsst.org,10.17.0.13',
      'wst-as01.cp.lsst.org,10.17.0.14',
      'dimm-as01.cp.lsst.org,10.17.0.15',
      'sky-as01.cp.lsst.org,10.17.0.16',
      'gen-as01.cp.lsst.org,10.17.0.17',
      'cam-as01.cp.lsst.org,10.17.0.2',
      'comp-ds01.cp.lsst.org,10.17.0.254',
      'comp-prep01.cp.lsst.org,10.17.0.23',
      'comp-is01.cp.lsst.org,10.17.0.32',
      'comp-is02.cp.lsst.org,10.17.0.33',
      'comp-is03.cp.lsst.org,10.17.0.34',
      'comp-is04.cp.lsst.org,10.17.0.35',
      'comp-is05.cp.lsst.org,10.17.0.36',
      'comp-is06.cp.lsst.org,10.17.0.37',
      'comp-is07.cp.lsst.org,10.17.0.38',
      'comp-is08.cp.lsst.org,10.17.0.39',
      'rot-as01.cp.lsst.org,10.17.0.40',
      'comp-as01.cp.lsst.org,10.17.0.51',
      'comp-as02.cp.lsst.org,10.17.0.52',
      'coat-as01.cp.lsst.org,10.17.0.53',
      'main5-as01.cp.lsst.org,10.17.0.54',
      'main7-as01.cp.lsst.org,10.17.0.71',
      'm1m3-as01.cp.lsst.org,10.17.0.6',
    ]
    $gw_list  = [
      'Vlan1090_k3s-testing,198.19.128.126',
      'Vlan1100_IT-MGMT,10.17.0.254',
      'Vlan1112_IT-USERS-A,139.229.163.254',
      'Vlan1121_IT-VOIP,10.17.1.254',
      'Vlan1123_IT-AP,10.17.3.254',
      'Vlan1125_IT-MISC,10.17.5.254',
      'Vlan1127_IT-CCTV,10.17.7.254',
      'Vlan1196_IT-CONTRACTORS,139.229.191.126',
      'Vlan1198_IT-GUEST,139.229.191.254',
      'Vlan1600_TCS_APP,139.229.178.254',
      'Vlan1601_TCS_EAS,139.229.178.254',
      'Vlan1300_OCS,139.229.167.254',
      'Vlan1301_OCS_EFD,139.229.167.254',
      'Vlan1302_OCS_PTP,139.229.167.254',
      'Vlan1903_IPMI_SRV,10.18.3.254',
      'Vlan1905_IPMI_PXE,10.18.5.254',
      'Vlan1901_IPMI_PDU,10.18.1.254',
      'Vlan1900_IPMI_NET,10.18.0.254',
      'Vlan1101_GSS,139.229.160.254',
      'Vlan1500_CSS,139.229.174.254',
      'Vlan1400_AUX,139.229.170.254',
      'Vlan1502_ACCS,139.229.175.254',
      'comp-wlc.cp.lsst.org,139.229.160.100'
    ]
  }

  #Hosts Template Array
  $host_templates = [
    $network_host_template_name,
    $gateway_host_template_name,
  ]
  #Network Services Array
  $network_services = [
    "${$intstat_svc_template_name},${network_svc_intstat_name}",
    "${$interror_svc_template_name},${network_svc_interror_name}",
    "${$env_svc_template_name},${network_svc_env_name}",
  ]
  #Network Templates Array
  $service_template = [
    "${intstat_svc_template_name},interface-usage",
    "${interror_svc_template_name},interface-errors",
    "${env_svc_template_name},hardware-health",
  ]
  #Hostgroups Array
  $hostgroups = [
    "host.display_name=%22bdc%2A%22|host.display_name=%22nob%2A%22|host.display_name=%22rubinobs%2A%22,NetworkDevices,${network_hostgroup_name}",
    "host.display_name=%22Vlan%2A%22,Base Gateways,${gateway_hostgroup_name}",
  ]

  #Commands abreviation
  $url_cmd       = "https://${master_fqdn}/director/command"
  $url_notify    = "https://${master_fqdn}/director/notification"
  $url_host      = "https://${master_fqdn}/director/host"
  $url_svc       = "https://${master_fqdn}/director/service"
  $url_hostgroup = "https://${master_fqdn}/director/hostgroup"
  $credentials   = "Authorization:Basic ${credentials_hash}"
  $format        = 'Accept: application/json'
  $curl          = 'curl -s -k -H'
  $icinga_path   = '/opt/icinga'
  $lt            = '| grep Failed'

  #<-----------------------End Variables Definition----------------------->
  #
  #
  #<-------------------Files Creation and deployement--------------------->
  #  Network Host Template
  $host_templates.each |$host| {
    $host_path = "${$icinga_path}/${host}.json"
    $host_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${host}' ${lt}"
    $host_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${host_path}"

    file { $host_path:
      ensure  => 'present',
      content => @("TEMPLATE"/L)
        {
        "accept_config": false,
        "check_command": "hostalive",
        "has_agent": false,
        "master_should_connect": false,
        "max_check_attempts": "5",
        "object_name": "${host}",
        "object_type": "template"
        }
        | TEMPLATE
    }
    ->exec { $host_cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $host_cond,
      loglevel => debug,
    }
  }

  #  Network Hosts
  $host_list.each |$host| {
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
          "${network_host_template_name}"
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
  #  Gateways
  $gw_list.each |$gw| {
    $value = split($gw,',')
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
          "${gateway_host_template_name}"
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
  #  Network Service Templates
  $service_template.each |$names| {
    $value = split($names,',')
    $svc_template_path = "${icinga_path}/${value[0]}.json"
    $svc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${value[0]}' ${lt}"
    $svc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$svc_template_path}"

    file { $svc_template_path:
      ensure  => 'present',
      content => @("SVC_TEMPLATE_CONTENT"/L)
        {
        "check_command": "${nwc_name}",
        "object_name": "${value[0]}",
        "object_type": "template",
        "vars": {
          "nwc_health_community": "${community}",
          "nwc_health_mode": "${value[1]}",
          "nwc_health_statefilesdir": "/tmp/"
        },
        "use_agent": false,
        "zone": "master"
        }
        | SVC_TEMPLATE_CONTENT
    }
    -> exec { $svc_template_cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $svc_template_cond,
      loglevel => debug,
    }
  }
  #  Network Services
  $network_services.each |$nservice| {
    $value = split($nservice, ',')
    $svc_path = "${icinga_path}/${value[1]}.json"
    $svc_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${value[1]}&host=${network_host_template_name}' ${lt}"
    $svc_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${svc_path}"

    file { $svc_path:
      ensure  => 'present',
      content => @("SVC"/L)
        {
        "host": "${network_host_template_name}",
        "imports": [
          "${$value[0]}"
        ],
        "object_name": "${value[1]}",
        "object_type": "object"
        }
        | SVC
    }
    -> exec { $svc_cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $svc_cond,
      loglevel => debug,
    }
  }

  #  Hostgroups
  $hostgroups.each |$hnames| {
    $value = split($hnames,',')
    $hostgroup_path = "${icinga_path}/${value[2]}.json"
    $hostgroup_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_hostgroup}?name=${value[2]}' ${lt}"
    $hostgroup_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_hostgroup}' -d @${hostgroup_path}"

    file { $hostgroup_path:
      ensure  => 'present',
      content => @("HOSTGROUP"/L)
        {
        "assign_filter": "${value[0]}",
        "display_name": "${value[1]}",
        "object_name": "${value[2]}",
        "object_type": "object"
        }
        | HOSTGROUP
    }
    ->exec { $hostgroup_cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $hostgroup_cond,
      loglevel => debug,
    }
  }
}

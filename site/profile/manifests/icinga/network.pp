# @summary
#   Define and create icinga objects for network monitoring

class profile::icinga::network (
  String $credentials_hash,
  String $network_username,
){
  #<-------------------------Variables Definition------------------------->
  #Implicit usage of facts
  $master_fqdn  = $facts[fqdn]
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

  $command_host_name               = 'notify-cmd-host'
  $command_svc_name                = 'notify-cmd-svc'
  $host_notification_template_name = 'host-network-notification-template'
  $svc_notification_template_name  = 'svc-network-notification-template'
  $host_notification_name          = 'notify-network-host'
  $svc_notification_name           = 'notify-server-svc'

  #Hosts Name Array
  $community   = 'rubinobs'
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
    'bdc-is10.ls.lsst.org,10.49.0.34',
    'bdc-is13.ls.lsst.org,10.49.0.37',
    'bdc-is14.ls.lsst.org,10.49.0.38',
    'bdc-as01.ls.lsst.org,10.49.0.91',
    'bdc-as02.ls.lsst.org,10.49.0.92',
    'bdc-ds01.ls.lsst.org,10.49.0.254',
    'bdc-cr01.ls.lsst.org,10.48.1.1',
    'bdc-cr02.ls.lsst.org,10.48.1.2',
    'rubinobs-br01.ls.lsst.org,10.48.1.4',
    'cube.ls.lsst.org,139.229.134.1',
  ]
  $gw_list  = [
    'VLAN2100,10.49.0.254',
    'Vlan900,192.168.255.4',
    'Vlan2100,10.49.0.254',
    'Vlan2101,139.229.134.254',
    'Vlan2102,139.229.135.254',
    'Vlan2113,139.229.158.190',
    'Vlan2114,139.229.158.254',
    'Vlan2115,139.229.159.126',
    'Vlan2116,139.229.159.254',
    'Vlan2121,10.49.1.254 ',
    'Vlan2123,10.49.3.254',
    'Vlan2125,10.49.5.254',
    'Vlan2200,139.229.149.254',
    'Vlan2300,139.229.144.126',
    'Vlan2400,139.229.147.254',
    'Vlan2401,139.229.146.254',
    'Vlan2402,139.229.148.254',
    'Vlan2500,139.229.150.126',
    'Vlan2903,10.50.3.254',
    'Vlan300,198.32.252.233',
    'Vlan301,198.32.252.235',
    'Vlan330,139.229.140.130',
    'Vlan340,139.229.140.132',
    'Vlan350,139.229.140.1',
    'Vlan360,139.229.140.134',
    'Vlan370,139.229.140.136',
  ]
  $host_templates = [
    $network_host_template_name,
    $gateway_host_template_name,
  ]
  #Services Array
  $services = [
    "${$intstat_svc_template_name},${network_svc_intstat_name}",
    "${$interror_svc_template_name},${network_svc_interror_name}",
    "${$env_svc_template_name},${network_svc_env_name}",
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
  #<-----------------------------JSON Files ------------------------------>
  #Service Template JSON
  $intstat_svc_template_content = @("INTSTAT_SVC_TEMPLATE_CONTENT"/L)
    {
    "check_command": "${nwc_name}",
    "object_name": "${intstat_svc_template_name}",
    "object_type": "template",
    "vars": {
      "enable_network_pagerduty": "true",
      "nwc_health_community": "${community}",
      "nwc_health_mode": "interface-usage",
      "nwc_health_statefilesdir": "/tmp/"
    },
    "use_agent": false,
    "zone": "master"
    }
    | INTSTAT_SVC_TEMPLATE_CONTENT
  $interror_svc_template_content = @("INTERROR_SVC_TEMPLATE_CONTENT"/L)
    {
    "check_command": "${nwc_name}",
    "object_name": "${interror_svc_template_name}",
    "object_type": "template",
    "vars": {
      "enable_network_pagerduty": "true",
      "nwc_health_community": "${community}",
      "nwc_health_mode": "interface-errors",
      "nwc_health_statefilesdir": "/tmp/"
    },
    "use_agent": false,
    "zone": "master"
    }
    | INTERROR_SVC_TEMPLATE_CONTENT
  $env_svc_template_content = @("ENV_SVC_TEMPLATE_CONTENT"/L)
    {
    "check_command": "${nwc_name}",
    "object_name": "${env_svc_template_name}",
    "object_type": "template",
    "vars": {
      "enable_network_pagerduty": "true",
      "nwc_health_community": "${community}",
      "nwc_health_mode": "hardware-health",
      "nwc_health_statefilesdir": "/tmp/"
    },
    "use_agent": false,
    "zone": "master"
    }
    | ENV_SVC_TEMPLATE_CONTENT

  #Notifications Template
  $host_notification_template = @("HOST_NOTIFICATION_TEMPLATE")
    {
    "command": "${command_host_name}",
    "notification_interval": "300",
    "object_name": "${host_notification_template_name}",
    "object_type": "template",
    "states": [
        "Down",
        "Up"
    ],
    "types": [
        "Acknowledgement",
        "Problem",
        "Recovery"
    ],
    "users": [
        "${network_username}"
    ],
    "zone": "master"
    }
    | HOST_NOTIFICATION_TEMPLATE
  $svc_notification_template = @("SVC_NOTIFICATION_TEMPLATE")
    {
    "command": "${command_svc_name}",
    "notification_interval": "300",
    "object_name": "${svc_notification_template_name}",
    "object_type": "template",
    "states": [
      "OK",
      "Warning",
      "Critical",
      "Unknown"
    ],
    "types": [
      "Acknowledgement",
      "Problem",
      "Recovery"
    ],
    "users": [
        "${network_username}"
    ],
    "zone": "master"
    }
    | SVC_NOTIFICATION_TEMPLATE

  #Notifications
  $host_notification = @("HOST_NOTIFICATION")
    {
    "apply_to": "host",
    "assign_filter": "host.vars.enable_network_pagerduty=%22true%22",
    "imports": [
        "${host_notification_template_name}"
    ],
    "object_name": "${host_notification_name}",
    "object_type": "apply",
    "states": [
        "Down",
        "Up"
    ],
    "types": [
        "Acknowledgement",
        "Problem",
        "Recovery"
    ],
    "users": [
        "${network_username}"
    ]
    }
    | HOST_NOTIFICATION
  $svc_notification = @("SERVICE_NOTIFICATION")
    {
    "apply_to": "service",
    "assign_filter": "service.vars.enable_network_pagerduty=%22true%22",
    "imports": [
        "${svc_notification_template_name}"
    ],
    "object_name": "${svc_notification_name}",
    "object_type": "apply",
    "states": [
      "OK",
      "Warning",
      "Critical",
      "Unknown"
    ],
    "types": [
        "Acknowledgement",
        "Problem",
        "Recovery"
    ],
    "users": [
        "${network_username}"
    ]
    }
    | SERVICE_NOTIFICATION
  ##Network HostGroup Definition
  $network_hostgroup = @("NETWORK_HOSTGROUP"/L)
    {
    "assign_filter": "host.display_name=%22bdc%2A%22|host.display_name=%22nob%2A%22|host.display_name=%22rubinobs%2A%22",
    "display_name": "Network Devices",
    "object_name": "${network_hostgroup_name}",
    "object_type": "object"
    }
    | NETWORK_HOSTGROUP
  $gateway_hostgroup = @("GATEWAY_HOSTGROUP"/L)
    {
    "assign_filter": "host.display_name=%22VLAN%2A%22",
    "display_name": "Base Gateways",
    "object_name": "${gateway_hostgroup_name}",
    "object_type": "object"
    }
    | GATEWAY_HOSTGROUP
  #<----------------------------End JSON Files----------------------------->
  #
  #
  #<--------------------Templates-Variables-Creation----------------------->
  #Service Template
  $intstat_svc_template_path = "${icinga_path}/${intstat_svc_template_name}.json"
  $intstat_svc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${intstat_svc_template_name}' ${lt}"
  $intstat_svc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$intstat_svc_template_path}"

  $interror_svc_template_path = "${icinga_path}/${interror_svc_template_name}.json"
  $interror_svc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${interror_svc_template_name}' ${lt}"
  $interror_svc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$interror_svc_template_path}"

  $env_svc_template_path = "${icinga_path}/${env_svc_template_name}.json"
  $env_svc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${env_svc_template_name}' ${lt}"
  $env_svc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$env_svc_template_path}"

  #Notification Template
  $host_notification_template_path = "${$icinga_path}/${host_notification_template_name}.json"
  $host_notification_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_notify}?name=${host_notification_template_name}' ${lt}"
  $host_notification_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_notify}' -d @${host_notification_template_path}"

  $svc_notification_template_path = "${$icinga_path}/${svc_notification_template_name}.json"
  $svc_notification_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_notify}?name=${svc_notification_template_name}' ${lt}"
  $svc_notification_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_notify}' -d @${svc_notification_template_path}"

  #Notification Creation
  $host_notification_path = "${$icinga_path}/${host_notification_name}.json"
  $host_notification_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_notify}?name=${host_notification_name}' ${lt}"
  $host_notification_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_notify}' -d @${host_notification_path}"

  $svc_notification_path = "${$icinga_path}/${svc_notification_name}.json"
  $svc_notification_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_notify}?name=${svc_notification_name}' ${lt}"
  $svc_notification_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_notify}' -d @${svc_notification_path}"

  #HostGroup Creation
  $network_hostgroup_path = "${icinga_path}/${network_hostgroup_name}.json"
  $network_hostgroup_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_hostgroup}?name=${network_hostgroup_name}' ${lt}"
  $network_hostgroup_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_hostgroup}' -d @${network_hostgroup_path}"

  $gateway_hostgroup_path = "${icinga_path}/${gateway_hostgroup_name}.json"
  $gateway_hostgroup_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_hostgroup}?name=${gateway_hostgroup_name}' ${lt}"
  $gateway_hostgroup_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_hostgroup}' -d @${gateway_hostgroup_path}"

  #<------------------END-Templates-Variables-Creation-------------------->
  #
  #
  #<-------------------Files Creation and deployement--------------------->
  ##Network Host Template
  #Create network template file
  $host_templates.each |$host|{
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
        "vars": {
            "enable_network_pagerduty": "true"
        },
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

  ##Network Hosts
  $host_list.each |$host|{
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
  #Gateways
  $gw_list.each |$gw|{
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
  ##Service Template
  #Create Interface Status Service Template file
  file { $intstat_svc_template_path:
    ensure  => 'present',
    content => $intstat_svc_template_content,
    before  => Exec[$intstat_svc_template_cmd],
  }
  #Add Interface Status Service Template
  exec { $intstat_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $intstat_svc_template_cond,
    loglevel => debug,
  }
  #Create Interface Error Service Template file
  file { $interror_svc_template_path:
    ensure  => 'present',
    content => $interror_svc_template_content,
    before  => Exec[$interror_svc_template_cmd],
  }
  #Add Interface Error Service Template
  exec { $interror_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $interror_svc_template_cond,
    loglevel => debug,
  }
  #Create Environmental Service Template file
  file { $env_svc_template_path:
    ensure  => 'present',
    content => $env_svc_template_content,
    before  => Exec[$env_svc_template_cmd],
  }
  #Add Environmental Service Template
  exec { $env_svc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $env_svc_template_cond,
    loglevel => debug,
  }

  ##Network Services
  $services.each |$nservice|{
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
        "vars": {
          "enable_network_pagerduty": "true"
        },
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

  ##Notification Templates
  #Create Host Notification Template file
  file { $host_notification_template_path:
    ensure  => 'present',
    content => $host_notification_template,
    before  => Exec[$host_notification_template_cmd],
  }
  #Add Host Notification Template
  exec { $host_notification_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $host_notification_template_cond,
    loglevel => debug,
  }
  #Create Service Notification Template file
  file { $svc_notification_template_path:
    ensure  => 'present',
    content => $svc_notification_template,
    before  => Exec[$svc_notification_template_cmd],
  }
  #Add Service Notification Template
  exec { $svc_notification_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $svc_notification_template_cond,
    loglevel => debug,
  }

  ##Host and Services Notification
  #Create Host Notification file
  file { $host_notification_path:
    ensure  => 'present',
    content => $host_notification,
    before  => Exec[$host_notification_cmd],
  }
  #Add Host Notification
  exec { $host_notification_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $host_notification_cond,
    loglevel => debug,
  }
  #Create Service Notification file
  file { $svc_notification_path:
    ensure  => 'present',
    content => $svc_notification,
    before  => Exec[$svc_notification_cmd],
  }
  #Add Service Notification
  exec { $svc_notification_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $svc_notification_cond,
    loglevel => debug,
  }

  ##Hostgroups
  #Create Network Hostgroup file
  file { $network_hostgroup_path:
    ensure  => 'present',
    content => $network_hostgroup,
    before  => Exec[$network_hostgroup_cmd],
  }
  #Add Network Hostgroup 
  exec { $network_hostgroup_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $network_hostgroup_cond,
    loglevel => debug,
  }
  #Create Gateways Hostgroup file
  file { $gateway_hostgroup_path:
    ensure  => 'present',
    content => $gateway_hostgroup,
    before  => Exec[$gateway_hostgroup_cmd],
  }
  #Add Gateways Hostgroup 
  exec { $gateway_hostgroup_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $gateway_hostgroup_cond,
    loglevel => debug,
  }
}

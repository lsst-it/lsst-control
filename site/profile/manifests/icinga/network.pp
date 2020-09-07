# @summary
#   Define and create icinga objects for network monitoring

class profile::icinga::network (
  String $credentials_hash,
){

  #<-------------------------Variables Definition------------------------->
  #Implicit usage of facts
  $master_fqdn  = $facts[fqdn]
  #Names Definition
  $user_name                  = 'pagerduty'
  $nwc_name                   = 'nwc_health'
  $nwc_notification_name      = 'nwc-template'
  $network_host_template_name = 'NetworkHostTemplate'

  $intstat_svc_template_name  = 'InterfaceStatusServiceTemplate'
  $interror_svc_template_name = 'InterfaceErrorsServiceTemplate'
  $env_svc_template_name      = 'EnvironmentServiceTemplate'

  $network_svc_intstat_name   = 'NetworkInterfaceStatusService'
  $network_svc_interror_name  = 'NetworkInterfaceErrorsService'
  $network_svc_env_name       = 'NetworkEnvironmentalService'

  #Hosts Name
  $community  = 'rubinobs'
  $host8_name = 'nob2-as04.ls.lsst.org'
  $host8_ip   = '10.49.0.24'

  #Commands abreviation
  $url_cmd     = "https://${master_fqdn}/director/command"
  $url_notify  = "https://${master_fqdn}/director/notification"
  $url_host    = "https://${master_fqdn}/director/host"
  $url_svc     = "https://${master_fqdn}/director/service"
  $credentials = "Authorization:Basic ${credentials_hash}"
  $format      = 'Accept: application/json'
  $curl        = 'curl -s -k -H'
  $icinga_path = '/opt/icinga'
  $lt          = '| grep Failed'

  #<-----------------------End Variables Definition----------------------->
  #
  #
  #<-----------------------------JSON Files ------------------------------>
  #Network Host Template
  $network_host_template_content = @("NETWORK"/L)
    {
    "accept_config": false,
    "check_command": "hostalive",
    "has_agent": false,
    "master_should_connect": false,
    "max_check_attempts": "5",
    "vars": {
        "enable_pagerduty": "true"
    },
    "object_name": "${network_host_template_name}",
    "object_type": "template"
    }
    | NETWORK

  #Service Template JSON
  $intstat_svc_template_content = @("INTSTAT_SVC_TEMPLATE_CONTENT"/L)
    {
    "check_command": "${nwc_name}",
    "object_name": "${intstat_svc_template_name}",
    "object_type": "template",
    "vars": {
      "enable_pagerduty": "true",
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
      "enable_pagerduty": "true",
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
      "enable_pagerduty": "true",
      "nwc_health_community": "${community}",
      "nwc_health_mode": "hardware-health",
      "nwc_health_statefilesdir": "/tmp/"
    },
    "use_agent": false,
    "zone": "master"
    }
    | ENV_SVC_TEMPLATE_CONTENT

  #Interface Status Service
  $network_svc1 = @("NETWORK_SVC1"/L)
    {
    "host": "${network_host_template_name}",
    "imports": [
      "${$intstat_svc_template_name}"
    ],
    "object_name": "${network_svc_intstat_name}",
    "vars": {
      "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | NETWORK_SVC1
  $network_svc2 = @("NETWORK_SVC2"/L)
    {
    "host": "${network_host_template_name}",
    "imports": [
      "${$interror_svc_template_name}"
    ],
    "object_name": "${network_svc_interror_name}",
    "vars": {
      "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | NETWORK_SVC2
  $network_svc3 = @("NETWORK_SVC3"/L)
    {
    "host": "${network_host_template_name}",
    "imports": [
      "${$env_svc_template_name}"
    ],
    "object_name": "${network_svc_env_name}",
    "vars": {
      "enable_pagerduty": "true"
    },
    "object_type": "object"
    }
    | NETWORK_SVC3

  #nwc-health notification 
  $nwc_notification_content = @("NWC_NOTIFICATION_CONTENT")
    {
    "command": "${nwc_name}",
    "notification_interval": "300",
    "object_name": "${nwc_notification_name}",
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
        "${user_name}"
    ],
    "zone": "master"
    }
    | NWC_NOTIFICATION_CONTENT

  ##Network Hosts
  # nob02-as-04
  $host8_content = @("HOST8_CONTENT"/L)
    {
    "address": "${host8_ip}",
    "display_name": "${host8_name}",
    "imports": [
      "${network_host_template_name}"
    ],
    "object_name":"${host8_name}",
    "object_type": "object",
    "vars": {
        "safed_profile": "3"
    },
    "zone": "master"
    }
    | HOST8_CONTENT

  #<----------------------------End JSON Files----------------------------->
  #
  #
  #<--------------------Templates-Variables-Creation----------------------->
  #Network Host Template
  $network_host_template_path = "${$icinga_path}/${network_host_template_name}.json"
  $network_host_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${network_host_template_name}' ${lt}"
  $network_host_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${network_host_template_path}"

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

  #Services Creation
  $network_svc1_path = "${icinga_path}/${network_svc_intstat_name}.json"
  $network_svc1_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${network_svc_intstat_name}&host=${network_host_template_name}' ${lt}"
  $network_svc1_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${network_svc1_path}"

  $network_svc2_path = "${icinga_path}/${network_svc_interror_name}.json"
  $network_svc2_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${network_svc_interror_name}&host=${network_host_template_name}' ${lt}"
  $network_svc2_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${network_svc2_path}"

  $network_svc3_path = "${icinga_path}/${network_svc_env_name}.json"
  $network_svc3_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${network_svc_env_name}&host=${network_host_template_name}' ${lt}"
  $network_svc3_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${network_svc3_path}"

  #Notification Creation
  $nwc_notification_path = "${$icinga_path}/${nwc_notification_name}.json"
  $nwc_notification_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_notify}?name=${nwc_notification_name}' ${lt}"
  $nwc_notification_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_notify}' -d @${nwc_notification_path}"

  #Hosts Creation
  $host8_path = "${icinga_path}/${host8_name}.json"
  $host8_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${host8_name}' ${lt}"
  $host8_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${host8_path}"

  #<------------------END-Templates-Variables-Creation-------------------->
  #
  #
  #<-------------------Files Creation and deployement--------------------->
  ##Network Host Template
  #Create network template file
  file { $network_host_template_path:
    ensure  => 'present',
    content => $network_host_template_content,
    before  => Exec[$network_host_template_cmd],
  }
  #Add general host template
  exec { $network_host_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $network_host_template_cond,
    loglevel => debug,
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
  #Create Interface Status Service file
  file { $network_svc1_path:
    ensure  => 'present',
    content => $network_svc1,
    before  => Exec[$network_svc1_cmd],
  }
  #Add Interface Status Service 
  exec { $network_svc1_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $network_svc1_cond,
    loglevel => debug,
  }

  #Create Interface Error Service file
  file { $network_svc2_path:
    ensure  => 'present',
    content => $network_svc2,
    before  => Exec[$network_svc2_cmd],
  }
  #Add Interface Error Service 
  exec { $network_svc2_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $network_svc2_cond,
    loglevel => debug,
  }
  #Create Environmental Service file
  file { $network_svc3_path:
    ensure  => 'present',
    content => $network_svc3,
    before  => Exec[$network_svc3_cmd],
  }
  #Add Environmental Service 
  exec { $network_svc3_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $network_svc3_cond,
    loglevel => debug,
  }

  ##Notification Templates
  #Create NWC Notification Template file
  file { $nwc_notification_path:
    ensure  => 'present',
    content => $nwc_notification_content,
    before  => Exec[$nwc_notification_cmd],
  }
  #Add NWC Notification Template
  exec { $nwc_notification_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $nwc_notification_cond,
    loglevel => debug,
  }

  ##Network Hosts
  #Create Host 8 file
  file { $host8_path:
    ensure  => 'present',
    content => $host8_content,
    before  => Exec[$host8_cmd],
  }
  #Add Host 8
  exec { $host8_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $host8_cond,
    loglevel => debug,
  }
}

# @summary
#   Define and create icinga objects for pagerduty integration
#   Instructions taken from https://www.pagerduty.com/docs/guides/icinga2-perl-integration-guide/

class profile::icinga::pagerduty (
  String $pagerduty_server_api,
  String $pagerduty_network_api,
  String $credentials_hash,
  String $server_username,
  String $network_username,
){

  #<-------------------------Variables Definition------------------------->
  #Implicit usage of facts
  $master_fqdn  = $facts[fqdn]

  #Names Definition
  $server_user_template            = "${server_username}-template"
  $network_user_template           = "${network_username}-template"
  $command_host_name               = 'notify-cmd-host'
  $command_svc_name                = 'notify-cmd-svc'
  $host_notification_template_name = 'host-server-notification-template'
  $svc_notification_template_name  = 'svc-server-notification-template'
  $host_notification_name          = 'notify-server-host'
  $svc_notification_name           = 'notify-server-service'

  #Hosts Template Array
  $user_template_array = [
    $server_user_template,
    $network_user_template,
  ]
  #Users Template Array
  $users_array = [
    "Servers PagerDuty Notification,${server_user_template},${server_username},${pagerduty_server_api}",
    "Network PagerDuty Notification,${network_user_template},${network_username},${pagerduty_network_api}",
  ]

  #Commands abreviation
  $url_cmd     = "https://${master_fqdn}/director/command"
  $url_notify  = "https://${master_fqdn}/director/notification"
  $url_usr     = "https://${master_fqdn}/director/user"
  $credentials = "Authorization:Basic ${credentials_hash}"
  $format      = 'Accept: application/json'
  $curl        = 'curl -s -k -H'
  $icinga_path = '/opt/icinga'
  $lt          = '| grep Failed'
  #Package Installation
  $packages = [
    'pdagent',
    'pdagent-integrations',
  ]
  #<-----------------------End Variables Definition----------------------->
  #
  #
  #<-----------------------------JSON Files ------------------------------>
  $command_host_content = @(COMMAND_HOST)
    {
    "arguments": {
        "-n": {
            "command_id": "232",
            "value": "host",
            "order": "0"
        },
        "-k": {
            "command_id": "232",
            "value": "$user.pager$",
            "order": "1"
        },
        "-t": {
            "command_id": "232",
            "value": "$notification.type$",
            "order": "2"
        },
        "-f": {
            "command_id": "232",
            "repeat_key": true,
            "value": "$f_args$",
            "order": "3"
        }
    },
    "command": "\/usr\/share\/pdagent-integrations\/bin\/pd-nagios",
    "methods_execute": "PluginNotification",
    "object_name": "notify-cmd-host",
    "object_type": "object",
    "vars": {
      "f_args" : [
        "HOSTNAME=$host.name$",
        "HOSTSTATE=$host.state$",
        "HOSTPROBLEMID=$host.state_id$",
        "HOSTOUTPUT=$host.output$"
      ]
    },
    "zone": "master"
    }
    | COMMAND_HOST
  $command_svc_content = @(COMMAND_SVC)
    {
    "arguments": {
        "-n": {
            "command_id": "234",
            "value": "service",
            "order": "0"
        },
        "-k": {
            "command_id": "234",
            "value": "$user.pager$",
            "order": "1"
        },
        "-t": {
            "command_id": "234",
            "value": "$notification.type$",
            "order": "2"
        },
        "-f": {
            "command_id": "234",
            "repeat_key": true,
            "value": "$f_args$",
            "order": "3"
        }        
    },
    "command": "\/usr\/share\/pdagent-integrations\/bin\/pd-nagios",
    "methods_execute": "PluginNotification",
    "object_name": "notify-cmd-svc",
    "object_type": "object",
    "vars": {
      "f_args" : [
        "SERVICEDESC=$service.name$",
        "SERVICEDISPLAYNAME=$service.display_name$",
        "HOSTNAME=$host.name$",
        "HOSTSTATE=$host.state$",
        "HOSTDISPLAYNAME=$host.display_name$",
        "SERVICESTATE=$service.state$",
        "SERVICEPROBLEMID=$service.state_id$",
        "SERVICEOUTPUT=$service.output$" 
      ]
    },    
    "zone": "master"
    }
    | COMMAND_SVC
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
        "${server_username}"
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
        "${server_username}"
    ],
    "zone": "master"
    }
    | SVC_NOTIFICATION_TEMPLATE
  $host_notification = @("HOST_NOTIFICATION")
    {
    "apply_to": "host",
    "assign_filter": "host.vars.enable_server_pagerduty=%22true%22",
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
        "${server_username}"
    ]
    }
    | HOST_NOTIFICATION
  $svc_notification = @("SERVICE_NOTIFICATION")
    {
    "apply_to": "service",
    "assign_filter": "service.vars.enable_server_pagerduty=%22true%22",
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
        "${server_username}"
    ]
    }
    | SERVICE_NOTIFICATION
  #<----------------------------End JSON Files----------------------------->
  #
  #
  #<--------------------Templates-Variables-Creation----------------------->

  $command_host_path = "${$icinga_path}/${command_host_name}.json"
  $command_host_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_cmd}?name=${command_host_name}' ${lt}"
  $command_host_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_cmd}' -d @${command_host_path}"

  $command_svc_path = "${$icinga_path}/${command_svc_name}.json"
  $command_svc_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_cmd}?name=${command_svc_name}' ${lt}"
  $command_svc_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_cmd}' -d @${command_svc_path}"

  $host_notification_template_path = "${$icinga_path}/${host_notification_template_name}.json"
  $host_notification_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_notify}?name=${host_notification_template_name}' ${lt}"
  $host_notification_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_notify}' -d @${host_notification_template_path}"

  $svc_notification_template_path = "${$icinga_path}/${svc_notification_template_name}.json"
  $svc_notification_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_notify}?name=${svc_notification_template_name}' ${lt}"
  $svc_notification_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_notify}' -d @${svc_notification_template_path}"

  $host_notification_path = "${$icinga_path}/${host_notification_name}.json"
  $host_notification_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_notify}?name=${host_notification_name}' ${lt}"
  $host_notification_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_notify}' -d @${host_notification_path}"

  $svc_notification_path = "${$icinga_path}/${svc_notification_name}.json"
  $svc_notification_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_notify}?name=${svc_notification_name}' ${lt}"
  $svc_notification_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_notify}' -d @${svc_notification_path}"

  #<------------------END-Templates-Variables-Creation-------------------->
  #
  #
  #<--------------------------Resources-Creation-------------------------->
  yumrepo { 'pdagent':
    ensure   => 'present',
    enabled  => true,
    descr    => 'PagerDuty Repo',
    baseurl  => 'https://packages.pagerduty.com/pdagent/rpm',
    gpgcheck => false,
    target   => '/etc/yum.repos.d/pdagent.repo',
  }
  #Packages Installation
  package { $packages:
    ensure  => 'present',
    require => Yumrepo['pdagent'],
  }
  #<------------------------END-Resources-Creation------------------------>
  #
  #
  #<-------------------Files Creation and deployement--------------------->
  ##Users Creation
  $user_template_array.each |$user_template|{
    $user_template_path = "${$icinga_path}/${user_template}.json"
    $user_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_usr}?name=${user_template}' ${lt}"
    $user_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_usr}' -d @${user_template_path}"

    file { $user_template_path:
      ensure  => 'present',
      content => @("USER_TEMPLATE_CONTENT")
        {
        "enable_notifications": true,
        "object_name": "${user_template}",
        "object_type": "template",
        "zone": "master"
        }
        | USER_TEMPLATE_CONTENT
    }
    -> exec { $user_template_cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $user_template_cond,
      loglevel => debug,
    }
  }
  $users_array.each |$users|{
    $value = split($users,',')
    $username_path = "${$icinga_path}/${value[2]}.json"
    $username_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_usr}?name=${value}' ${lt}"
    $username_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_usr}' -d @${username_path}"

    file { $username_path:
      ensure  => 'present',
      content => @("USER_CONTENT"/)
        {
        "display_name": "${value[0]}",
        "imports": [
            "${value[1]}"
        ],
        "object_name": "${value[2]}",
        "object_type": "object",
        "pager": "${value[3]}",
        "states": [
            "Down",
            "Up",
            "OK",
            "Warning",
            "Critical",
            "Unknown"
        ],
        "types": [
            "Acknowledgement",
            "Problem",
            "Recovery"
        ]
        }
        | USER_CONTENT
    }
    -> exec { $username_cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $username_cond,
      loglevel => debug,
    }
  }

  ##Host and Service Command
  #Create Host Command file
  file { $command_host_path:
    ensure  => 'present',
    content => $command_host_content,
    before  => Exec[$command_host_cmd],
  }
  #Add Host Command
  exec { $command_host_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $command_host_cond,
    loglevel => debug,
  }
  #Create Service Command file
  file { $command_svc_path:
    ensure  => 'present',
    content => $command_svc_content,
    before  => Exec[$command_svc_cmd],
  }
  #Add Service Command
  exec { $command_svc_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $command_svc_cond,
    loglevel => debug,
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

  ##Notifications
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
  #<-----------------------END-Files-Creation----------------------------->
  service { 'pdagent':
    ensure  => 'running',
    require => Package[$packages],
  }
}

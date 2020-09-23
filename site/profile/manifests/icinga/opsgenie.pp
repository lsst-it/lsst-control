# @summary
#   Define and integrate opsgenie to icinga2

class profile::icinga::opsgenie (
  String $opsgenie_api,
  String $credentials_hash,
  String $pager_user,
){

  #<-------------------------Variables Definition------------------------->
  #Implicit usage of facts
  $master_fqdn  = $facts['networking']['fqdn']

  #Names Definition
  $user_template                   = "${pager_user}-template"
  $command_host_name               = 'notify-cmd-host'
  $command_svc_name                = 'notify-cmd-svc'
  $host_notification_template_name = 'host-notification-template'
  $svc_notification_template_name  = 'svc-notification-template'
  $host_notification_name          = 'notify-host'
  $svc_notification_name           = 'notify-service'

  #Commands abreviation
  $url_cmd     = "https://${master_fqdn}/director/command"
  $url_notify  = "https://${master_fqdn}/director/notification"
  $url_usr     = "https://${master_fqdn}/director/user"
  $credentials = "Authorization:Basic ${credentials_hash}"
  $format      = 'Accept: application/json'
  $curl        = 'curl -s -k -H'
  $icinga_path = '/opt/icinga'
  $lt          = '| grep Failed'

  #Notification Template Array
  $notification_template = [
    "${command_host_name},${host_notification_template_name}",
    "${command_svc_name},${svc_notification_template_name}",
  ]
  #Notifications Array
  $notification = [
    "${host_notification_template_name},${host_notification_name},host",
    "${svc_notification_template_name},${svc_notification_name},service",
  ]
  #<-----------------------End Variables Definition----------------------->
  #
  #
  #<-----------------------OpsGenie-Configuration------------------------->
  package { 'opsgenie-icinga2':
    ensure => 'present',
    source => 'https://s3-us-west-2.amazonaws.com/opsgeniedownloads/repo/opsgenie-icinga2-2.17.0-1.all.noarch.rpm',
  }
  file { '/etc/opsgenie/conf/opsgenie-integration.conf':
    ensure  => 'present',
    owner   => 'opsgenie',
    group   => 'opsgenie',
    mode    => '0775',
    content => @("OPSGENIE")
      apiKey = ${opsgenie_api}
      icinga_server=default
      icinga2opsgenie.logger=warning
      icinga2opsgenie.timeout=60
      logPath=/var/log/opsgenie/icinga2opsgenie.log
      actions.Acknowledge.script=icingaActionExecutor.groovy
      actions.AddNote.script=icingaActionExecutor.groovy
      actions.TakeOwnership.script=icingaActionExecutor.groovy
      actions.AssignOwnership.script=icingaActionExecutor.groovy
      actions.Create.script=icingaActionExecutor.groovy
      | OPSGENIE
  }
  #<-------------------END-OpsGenie-Configuration------------------------->
  #
  #
  #<-------------------Files Creation and deployement--------------------->
  ##User Template Creation
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
  ->exec { $user_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $user_template_cond,
    loglevel => debug,
  }

  ##User Creation
  $pager_user_path = "${$icinga_path}/${pager_user}.json"
  $pager_user_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_usr}?name=${pager_user}' ${lt}"
  $pager_user_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_usr}' -d @${pager_user_path}"

  file { $pager_user_path:
    ensure  => 'present',
    content => @("USER_CONTENT"/)
    {
    "display_name": "Alert System Notification",
    "imports": [
      "${user_template}"
    ],
    "object_name": "${pager_user}",
    "object_type": "object"
    }
    | USER_CONTENT
  }
  ->exec { $pager_user_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $pager_user_cond,
    loglevel => debug,
  }

  ##Host and Service Command
  #Host Command Creation
  $command_host_path = "${$icinga_path}/${command_host_name}.json"
  $command_host_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_cmd}?name=${command_host_name}' ${lt}"
  $command_host_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_cmd}' -d @${command_host_path}"

  file { $command_host_path:
    ensure  => 'present',
    content => @(COMMAND_HOST)
      {
      "arguments": {
        "-entityType": {
          "command_id": "253",
          "value": "host"
        },
        "-t": {
          "command_id": "253",
          "value": "$notification.type$"
        },
        "-ldt": {
          "command_id": "253",
          "value": "$icinga.long_date_time$"
        },
        "-hn": {
          "command_id": "253",
          "value": "$host.name$"
        },
        "-hdn": {
          "command_id": "253",
          "value": "$host.display_name$"
        },
        "-hal": {
          "command_id": "253",
          "value": "$host.display_name$"
        },
        "-haddr": {
          "command_id": "253",
          "value": "$host.address$"
        },
        "-hs": {
          "command_id": "253",
          "value": "$host.state$"
        },
        "-hsi": {
          "command_id": "253",
          "value": "$host.state_id$"
        },
        "-lhs": {
          "command_id": "253",
          "value": "$host.last_state$"
        },
        "-lhsi": {
          "command_id": "253",
          "value": "$host.last_state_id$"
        },
        "-hst": {
          "command_id": "253",
          "value": "$host.state_type$"
        },
        "-ha": {
          "command_id": "253",
          "value": "$host.check_attempt$"
        },
        "-mha": {
          "command_id": "253",
          "value": "$host.max_check_attempts$"
        },
        "-hl": {
          "command_id": "253",
          "value": "$host.latency$"
        },
        "-het": {
          "command_id": "253",
          "value": "$host.execution_time$"
        },
        "-hds": {
          "command_id": "253",
          "value": "$host.duration_sec$"
        },
        "-hdt": {
          "command_id": "253",
          "value": "$host.downtime_depth$"
        },
        "-hgn": {
          "command_id": "253",
          "value": "$host.group$"
        },
        "-hgns": {
          "command_id": "253",
          "value": {
            "type": "Function",
            "body": "host.groups.join(\",\")"
          }
        },
        "-lhc": {
          "command_id": "253",
          "value": "$host.last_check$"
        },
        "-lhsc": {
           "command_id": "253",
          "value": "$host.last_state_change$"
        },
        "-ho": {
          "command_id": "253",
          "value": "$host.output$"
        },
        "-hpd": {
          "command_id": "253",
          "value": "$host.perfdata$"
        }
      },
      "command": "\/usr\/bin\/icinga2opsgenie",
      "methods_execute": "PluginNotification",
      "object_name": "notify-cmd-host",
      "object_type": "object",
      "zone": "master"
      }
      | COMMAND_HOST
  }
  ->exec { $command_host_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $command_host_cond,
    loglevel => debug,
  }
  #Service Command Creation
  $command_svc_path = "${$icinga_path}/${command_svc_name}.json"
  $command_svc_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_cmd}?name=${command_svc_name}' ${lt}"
  $command_svc_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_cmd}' -d @${command_svc_path}"

  file { $command_svc_path:
    ensure  => 'present',
    content => @(COMMAND_SVC)
      {
      "arguments": {
        "-entityType": {
          "command_id": "254",
          "value": "service"
        },
        "-t": {
          "command_id": "254",
          "value": "$notification.type$"
        },
        "-ldt": {
          "command_id": "254",
          "value": "$icinga.long_date_time$"
        },
        "-hn": {
          "command_id": "254",
          "value": "$host.name$"
        },
        "-hdn": {
          "command_id": "254",
          "value": "$host.display_name$"
        },
        "-hal": {
          "command_id": "254",
          "value": "$host.display_name$"
        },
        "-haddr": {
          "command_id": "254",
          "value": "$host.address$"
        },
        "-hs": {
          "command_id": "254",
          "value": "$host.state$"
        },
        "-hsi": {
          "command_id": "254",
          "value": "$host.state_id$"
        },
        "-lhs": {
          "command_id": "254",
          "value": "$host.last_state$"
        },
        "-lhsi": {
          "command_id": "254",
          "value": "$host.last_state_id$"
        },
        "-hst": {
          "command_id": "254",
          "value": "$host.state_type$"
        },
        "-ha": {
          "command_id": "254",
          "value": "$host.check_attempt$"
        },
        "-mha": {
          "command_id": "254",
          "value": "$host.max_check_attempts$"
        },
        "-hl": {
          "command_id": "254",
          "value": "$host.latency$"
        },
        "-het": {
          "command_id": "254",
          "value": "$host.execution_time$"
        },
        "-hds": {
          "command_id": "254",
          "value": "$host.duration_sec$"
        },
        "-hdt": {
          "command_id": "254",
          "value": "$host.downtime_depth$"
        },
        "-hgn": {
          "command_id": "254",
          "value": "$host.group$"
        },
        "-hgns": {
          "command_id": "254",
          "value": {
            "type": "Function",
            "body": "host.groups.join(\",\")"
          }
        },
        "-lhc": {
          "command_id": "254",
          "value": "$host.last_check$"
        },
        "-lhsc": {
          "command_id": "254",
          "value": "$host.last_state_change$"
        },
        "-ho": {
          "command_id": "254",
          "value": "$host.output$"
        },
        "-hpd": {
          "command_id": "254",
          "value": "$host.perfdata$"
        },
        "-s": {
          "command_id": "254",
          "value": "$service.name$"
        },
        "-sdn": {
          "command_id": "254",
          "value": "$service.display_name$"
        },
        "-ss": {
          "command_id": "254",
          "value": "$service.state$"
        },
        "-ssi": {
          "command_id": "254",
          "value": "$service.state_id$"
        },
        "-lss": {
          "command_id": "254",
          "value": "$service.last_state$"
        },
        "-lssi": {
          "command_id": "254",
          "value": "$service.last_state_id$"
        },
        "-sst": {
          "command_id": "254",
          "value": "$service.state_type$"
        },
        "-sa": {
          "command_id": "254",
          "value": "$service.check_attempt$"
        },
        "-sc": {
          "command_id": "254",
          "value": "$service.check_command$"
        },
        "-msa": {
          "command_id": "254",
          "value": "$service.max_check_attempts$"
        },
        "-sl": {
          "command_id": "254",
          "value": "$service.latency$"
        },
        "-set": {
          "command_id": "254",
          "value": "$service.execution_time$"
        },
        "-sds": {
          "command_id": "254",
          "value": "$service.duration_sec$"
        },
        "-sdt": {
          "command_id": "254",
          "value": "$service.downtime_depth$"
        },
        "-sgns": {
          "command_id": "254",
          "value": {
              "type": "Function",
              "body": "service.groups.join(\",\")"
          }
        },
        "-lsch": {
          "command_id": "254",
          "value": "$service.last_check$"
        },
        "-lssc": {
          "command_id": "254",
          "value": "$service.last_state_change$"
        },
        "-so": {
          "command_id": "254",
          "value": "$service.output$"
        },
        "-spd": {
          "command_id": "234",
          "value": "$service.perfdata$"
        }        
      },
      "command": "\/usr\/bin\/icinga2opsgenie",
      "methods_execute": "PluginNotification",
      "object_name": "notify-cmd-svc",
      "object_type": "object",
      "zone": "master"
      }
      | COMMAND_SVC
  }
  ->exec { $command_svc_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $command_svc_cond,
    loglevel => debug,
  }

  #Notification Templates
  $notification_template.each |$ntemplate|{
    $value = split($ntemplate, ',')
    $notification_template_path = "${$icinga_path}/${value[1]}.json"
    $notification_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_notify}?name=${value[1]}' ${lt}"
    $notification_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_notify}' -d @${notification_template_path}"

    file { $notification_template_path:
      ensure  => 'present',
      content => @("HOST_NOTIFICATION_TEMPLATE")
        {
        "command": "${value[0]}",
        "notification_interval": "60",
        "object_name": "${value[1]}",
        "object_type": "template",
        "users": [
            "${pager_user}"
        ],
        "zone": "master"
        }
        | HOST_NOTIFICATION_TEMPLATE
    }
    ->exec { $notification_template_cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $notification_template_cond,
      loglevel => debug,
    }
  }

  # ##Host and Services Notification
  $notification.each |$notify|{
    $value = split($notify,',')
    $notification_path = "${$icinga_path}/${value[1]}.json"
    $notification_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_notify}?name=${value[1]}' ${lt}"
    $notification_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_notify}' -d @${notification_path}"

    #Create Host Notification file
    file { $notification_path:
      ensure  => 'present',
      content => @("HOST_NOTIFICATION")
        {
        "apply_to": "${value[2]}",
        "assign_filter": "${value[2]}=true",
        "imports": [
            "${value[0]}"
        ],
        "object_name": "${value[1]}",
        "object_type": "apply",
        "users": [
            "${pager_user}"
        ]
        }
        | HOST_NOTIFICATION
    }
    ->exec { $notification_cmd:
      cwd      => $icinga_path,
      path     => ['/sbin', '/usr/sbin', '/bin'],
      provider => shell,
      onlyif   => $notification_cond,
      loglevel => debug,
    }
  }
  #<-----------------------END-Files-Creation----------------------------->
}

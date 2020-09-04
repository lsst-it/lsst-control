# @summary
#   Define and create icinga objects for network monitoring

class profile::core::icinga_netmon (
  String $credentials_hash,
){

  #<-------------------------Variables Definition------------------------->
  #Implicit usage of facts
  $master_fqdn  = $facts[fqdn]
  #Names Definition
  $user_name         = 'pagerduty'
  $nwc_name          = 'nwc-health'
  $nwc_template_name = 'nwc-template'
  #Commands abreviation
  $url_cmd     = "https://${master_fqdn}/director/command"
  $url_notify  = "https://${master_fqdn}/director/notification"
  $url_usr     = "https://${master_fqdn}/director/user"
  $credentials = "Authorization:Basic ${credentials_hash}"
  $format      = 'Accept: application/json'
  $curl        = 'curl -s -k -H'
  $icinga_path = '/opt/icinga'
  $lt          = '| grep Failed'

  #<-----------------------End Variables Definition----------------------->
  #
  #
  #<-----------------------------JSON Files ------------------------------>

  $nwc_content = @(NWC_CONTENT)
    {
    "arguments": {
        "--community": {
            "command_id": "248",
            "required": true,
            "value": "public"
        },
        "--hostname": {
            "command_id": "248",
            "required": true,
            "value": "$host.ipaddr$"
        },
        "--mode": {
            "command_id": "248",
            "repeat_key": true,
            "required": true,
            "value": "$f_args$"
        }
    },
    "command": "\/usr\/lib64\/nagios\/plugins\/check_nwc_health",
    "methods_execute": "PluginNotification",
    "object_name": "nwc-health",
    "object_type": "object",
    "zone": "master",
    "vars": {
      "f_args" : [
        "uptime",
        "hardware-health",
        "interface-status"
      ]
    }
  }
  | NWC_CONTENT

  $nwc_template = @("NWC_TEMPLATE")
    {
    "command": "${nwc_name}",
    "notification_interval": "300",
    "object_name": "${nwc_template_name}",
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
    | NWC_TEMPLATE
  #<----------------------------End JSON Files----------------------------->
  #
  #
  #<--------------------Templates-Variables-Creation----------------------->

  $nwc_path = "${$icinga_path}/${nwc_name}.json"
  $nwc_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_cmd}?name=${nwc_name}' ${lt}"
  $nwc_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_cmd}' -d @${nwc_path}"

  $nwc_template_path = "${$icinga_path}/${nwc_template_name}.json"
  $nwc_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_notify}?name=${nwc_template_name}' ${lt}"
  $nwc_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_notify}' -d @${nwc_template_path}"

  #<------------------END-Templates-Variables-Creation-------------------->
  #
  #
  #<-------------------Files Creation and deployement--------------------->

  ##NWC Health Command
  #Create nwc Command file
  file { $nwc_path:
    ensure  => 'present',
    content => $nwc_content,
    before  => Exec[$nwc_cmd],
  }
  #Add nwc Command
  exec { $nwc_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $nwc_cond,
    loglevel => debug,
  }

  ##Notification Templates
  #Create NWC Notification Template file
  file { $nwc_template_path:
    ensure  => 'present',
    content => $nwc_template,
    before  => Exec[$nwc_template_cmd],
  }
  #Add NWC Notification Template
  exec { $nwc_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $nwc_template_cond,
    loglevel => debug,
  }
}

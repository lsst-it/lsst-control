# @summary
#   Define and create icinga objects for pagerduty integration
#   Instructions taken from https://www.pagerduty.com/docs/guides/icinga2-perl-integration-guide/

class profile::core::icinga_pagerduty (
  String $pagerduty_api,
  String $credentials_hash,
){

  #<-------------------------Variables Definition------------------------->
  #Implicit usage of facts
  $master_fqdn  = $facts[fqdn]
  #Names Definition
  $user_template_name         = 'pagerduty-template'
  $user_name                  = 'pagerduty'
  $command_name               = 'pagerduty_cmd'
  $notification_template_name = 'pagerduty-cmd-template'
  $notification_host_name     = 'notify-host'
  $notification_svc_name      = 'notify-service'
  #Commands abreviation
  $url_cmd     = "https://${master_fqdn}/director/command"
  $url_notify  = "https://${master_fqdn}/director/notification"
  $url_usr     = "https://${master_fqdn}/director/user"
  $credentials = "Authorization:Basic ${credentials_hash}"
  $format      = 'Accept: application/json'
  $curl        = 'curl -s -k -H'
  $icinga_path = '/opt/icinga'
  $lt          = '| grep Failed'
  #Package INstallation
  $packages = [
    'pdagent',
    'pdagent-integrations',
  ]
  #<-----------------------End Variables Definition----------------------->
  #
  #
  #<-----------------------------JSON Files ------------------------------>
  $user_template = @("USER_TEMPLATE")
    {
    "enable_notifications": true,
    "object_name": "${user_template_name}",
    "object_type": "template",
    "zone": "master"
    }
    | USER_TEMPLATE
  $user_content = @("USER"/)
    {
    "display_name": "PagerDuty Notification User",
    "imports": [
        "${user_template_name}"
    ],
    "object_name": "${user_name}",
    "object_type": "object",
    "pager": "${pagerduty_api}",
    }
    | USER
  $command_content = @("COMMAND")
    {
    "command": "/usr/lib64/nagios/plugins/pagerduty_icinga.pl",
    "methods_execute": "PluginNotification",
    "object_name": "${command_name}",
    "object_type": "object",
    "zone": "master"
     }
    | COMMAND
  $notification_template = @("NOTIFY_TEMPLATE")
    {
    "command": "${command_name}",
    "notification_interval": "300",
    "object_name": "${notification_template_name}",
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
        "pagerduty"
    ],
    "zone": "master"
    }
    | NOTIFY_TEMPLATE
  $notification_svc = @("NOTIFY_SVC")
    {
    "apply_to": "service",
    "assign_filter": "service.vars.enable_pagerduty=%22true%22",
    "imports": [
        "${notification_template_name}"
    ],
    "object_name": "${notification_svc_name}",
    "object_type": "apply",
    "users": [
        "${user_name}"
    ]
    }
    | NOTIFY_SVC
  $notification_host = @("NOTIFY_HOST")
    {
    "apply_to": "host",
    "assign_filter": "host.vars.enable_pagerduty=%22true%22",
    "imports": [
        "${notification_template_name}"
    ],
    "object_name": "${notification_host_name}",
    "object_type": "apply",
    "users": [
        "${user_name}"
    ]
    }
    | NOTIFY_HOST
  #<----------------------------End JSON Files----------------------------->
  #
  #
  #<--------------------Templates-Variables-Creation----------------------->

  $user_template_path = "${$icinga_path}/${user_template_name}.json"
  $user_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_usr}?name=${user_template_name}' ${lt}"
  $user_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_usr}' -d @${user_template_path}"

  $user_path = "${$icinga_path}/${user_name}.json"
  $user_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_usr}?name=${user_name}' ${lt}"
  $user_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_usr}' -d @${user_path}"

  $command_path = "${$icinga_path}/${command_name}.json"
  $command_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_cmd}?name=${command_name}' ${lt}"
  $command_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_cmd}' -d @${command_path}"

  $notification_template_path = "${$icinga_path}/${notification_template_name}.json"
  $notification_template_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_notify}?name=${notification_template_name}' ${lt}"
  $notification_template_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_notify}' -d @${notification_template_path}"

  $notification_svc_path = "${$icinga_path}/${notification_svc_name}.json"
  $notification_svc_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_notify}?name=${notification_svc_name}' ${lt}"
  $notification_svc_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_notify}' -d @${notification_svc_path}"

  $notification_host_path = "${$icinga_path}/${notification_host_name}.json"
  $notification_host_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_notify}?name=${notification_host_name}' ${lt}"
  $notification_host_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_notify}' -d @${notification_host_path}"
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
  #Create User template file
  file { $user_template_path:
    ensure  => 'present',
    content => $user_template,
    before  => Exec[$user_template_cmd],
  }
  #Add User template
  exec { $user_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $user_template_cond,
    loglevel => debug,
  }
  #Create User file
  file { $user_path:
    ensure  => 'present',
    content => $user_content,
    before  => Exec[$user_cmd],
  }
  #Add User 
  exec { $user_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $user_cond,
    loglevel => debug,
  }
  #Create Command file
  file { $command_path:
    ensure  => 'present',
    content => $command_content,
    before  => Exec[$command_cmd],
  }
  #Add Command
  exec { $command_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $command_cond,
    loglevel => debug,
  }
  #Create Notification Template file
  file { $notification_template_path:
    ensure  => 'present',
    content => $notification_template,
    before  => Exec[$notification_template_cmd],
  }
  #Add Notification Template
  exec { $notification_template_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $notification_template_cond,
    loglevel => debug,
  }
  #Create Service Notification file
  file { $notification_svc_path:
    ensure  => 'present',
    content => $notification_svc,
    before  => Exec[$notification_svc_cmd],
  }
  #Add Service Notification
  exec { $notification_svc_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $notification_svc_cond,
    loglevel => debug,
  }
  #Create Host Notification file
  file { $notification_host_path:
    ensure  => 'present',
    content => $notification_host,
    before  => Exec[$notification_host_cmd],
  }
  #Add Host Notification
  exec { $notification_host_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $notification_host_cond,
    loglevel => debug,
  }
  exec { 'wget https://raw.github.com/PagerDuty/pagerduty-icinga-pl/master/pagerduty_icinga.pl':
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => 'test ! -f /var/tmp/pagerduty_icinga.pl',
    loglevel => debug,
  }
  ->file { '/usr/lib64/nagios/plugins/pagerduty_icinga.pl':
    ensure => 'present',
    source => '/var/tmp/pagerduty_icinga.pl',
    mode   => '4755',
    owner  => 'root',
    group  => 'icinga',
    notify => Service['icinga2'],
  }
  #<-----------------------END-Files-Creation----------------------------->
  service { 'pdagent':
    ensure  => 'running',
    require => Package[$packages],
  }
}

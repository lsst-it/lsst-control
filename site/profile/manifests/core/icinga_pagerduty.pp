# @summary
#   Define and create icinga objects for pagerduty integration
#   Instructions taken from https://www.pagerduty.com/docs/guides/icinga2-perl-integration-guide/

class profile::core::icinga_pagerduty (
  String $pagerduty_api,
){
  $pagerduty = @("PAGERDUTY"/)
    object User "pagerduty" {
      pager = "${pagerduty_api}"
      groups = [ "icingaadmins" ]
      display_name = "PagerDuty Notification User"
      states = [ OK, Warning, Critical, Unknown, Up, Down ]
      types = [ Problem, Acknowledgement, Recovery ]
    }
  | PAGERDUTY
  $notification_svc = @(NOTIFICATION_SVC)
    object NotificationCommand "notify-service-by-pagerduty" {
      import "plugin-notification-command"
      command = [ "/usr/lib64/nagios/plugins/pagerduty_icinga.pl" ]
      arguments = {
        "enqueue" = {
          skip_key = true
          order = 0
          value = "enqueue"
        }
        "-f" = {
          order = 1
          value = "pd_nagios_object=service"
        }
      }
      env = {
        "ICINGA_CONTACTPAGER" = "$user.pager$"
        "ICINGA_NOTIFICATIONTYPE" = "$notification.type$"
        "ICINGA_SERVICEDESC" = "$service.name$"
        "ICINGA_HOSTNAME" = "$host.name$"
        "ICINGA_HOSTALIAS" = "$host.display_name$"
        "ICINGA_SERVICESTATE" = "$service.state$"
        "ICINGA_SERVICEOUTPUT" = "$service.output$"
      }
    }
  | NOTIFICATION_SVC
  $notification_host = @(NOTIFICATION_HOST)
    object NotificationCommand "notify-host-by-pagerduty" {
      import "plugin-notification-command"
      command = [ "/usr/lib64/nagios/plugins/pagerduty_icinga.pl" ]
      arguments = {
        "enqueue" = {
          skip_key = true
          order = 0
          value = "enqueue"
        }
        "-f" = {
          order = 1
          value = "pd_nagios_object=host"
        }
      }
      env = {
        "ICINGA_CONTACTPAGER" = "$user.pager$"
        "ICINGA_NOTIFICATIONTYPE" = "$notification.type$"
        "ICINGA_HOSTNAME" = "$host.name$"
        "ICINGA_HOSTALIAS" = "$host.display_name$"
        "ICINGA_HOSTSTATE" = "$host.state$"
        "ICINGA_HOSTOUTPUT" = "$host.output$"
      }
    }
  | NOTIFICATION_HOST
  $pagerduty_svc = @(PAGERDUTY_SVC)
    apply Notification "pagerduty-service" to Service {
      command = "notify-service-by-pagerduty"
      states = [ OK, Warning, Critical, Unknown ]
      types = [ Problem, Acknowledgement, Recovery ]
      period = "24x7"
      users = [ "pagerduty" ]

      assign where service.vars.enable_pagerduty == true
    }
  | PAGERDUTY_SVC
  $pagerduty_host = @(PAGERDUTY_HOST)
    apply Notification "pagerduty-host" to Host {
      command = "notify-host-by-pagerduty"
      states = [ Up, Down ]
      types = [ Problem, Acknowledgement, Recovery ]
      period = "24x7"
      users = [ "pagerduty" ]

      assign where host.vars.enable_pagerduty == true
    }
  | PAGERDUTY_HOST

  file { '/etc/icinga2/features-enabled/pagerduty-notification_svc.conf':
    ensure  => 'present',
    content => $notification_svc,
    mode    => '0640',
    owner   => 'icinga',
    group   => 'icinga',
  }
  file { '/etc/icinga2/features-enabled/pagerduty-notification_host.conf':
    ensure  => 'present',
    content => $notification_host,
    mode    => '0640',
    owner   => 'icinga',
    group   => 'icinga',
  }
  file { '/etc/icinga2/features-enabled/pagerduty-svc.conf':
    ensure  => 'present',
    content => $pagerduty_svc,
    mode    => '0640',
    owner   => 'icinga',
    group   => 'icinga',
  }
  file { '/etc/icinga2/features-enabled/pagerduty-host.conf':
    ensure  => 'present',
    content => $pagerduty_host,
    mode    => '0640',
    owner   => 'icinga',
    group   => 'icinga',
  }
  file { '/usr/lib64/nagios/plugins/pagerduty_icinga.pl':
    ensure => 'present',
    source => 'https://raw.github.com/PagerDuty/pagerduty-icinga-pl/master/pagerduty_icinga.pl',
    mode   => '0755',
    owner  => 'root',
    group  => 'icinga',
    notify => Service['icinga2'],
  }
}

# @summary
#   Define and create icinga objects for pagerduty integration

class profile::core::icinga_pagerduty (
  String $pagerduty_api,
){
  $pagerduty_conf = @("PAGERDUTY"/)
    object User "pagerduty" {
      pager = "${pagerduty_api}"
      groups = [ "icingaadmins" ]
      display_name = "PagerDuty Notification User"
      states = [ OK, Warning, Critical, Unknown, Up, Down ]
      types = [ Problem, Acknowledgement, Recovery ]
    }

    object NotificationCommand "notify-service-by-pagerduty" {
      import "plugin-notification-command"
      command = [ "/usr/local/bin/pagerduty_icinga.pl" ]
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
        "ICINGA_CONTACTPAGER" = "\$user.pager$"
        "ICINGA_NOTIFICATIONTYPE" = "\$notification.type$"
        "ICINGA_SERVICEDESC" = "\$service.name$"
        "ICINGA_HOSTNAME" = "\$host.name$"
        "ICINGA_HOSTALIAS" = "\$host.display_name$"
        "ICINGA_SERVICESTATE" = "\$service.state$"
        "ICINGA_SERVICEOUTPUT" = "\$service.output$"
      }
    }

    object NotificationCommand "notify-host-by-pagerduty" {
      import "plugin-notification-command"
      command = [ "/usr/local/bin/pagerduty_icinga.pl" ]
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
        "ICINGA_CONTACTPAGER" = "\$user.pager$"
        "ICINGA_NOTIFICATIONTYPE" = "$\notification.type$"
        "ICINGA_HOSTNAME" = "\$host.name$"
        "ICINGA_HOSTALIAS" = "\$host.display_name$"
        "ICINGA_HOSTSTATE" = "\$host.state$"
        "ICINGA_HOSTOUTPUT" = "\$host.output$"
      }
    }

    apply Notification "pagerduty-service" to Service {
      command = "notify-service-by-pagerduty"
      states = [ OK, Warning, Critical, Unknown ]
      types = [ Problem, Acknowledgement, Recovery ]
      period = "24x7"
      users = [ "pagerduty" ]

      assign where service.vars.enable_pagerduty == true
    }

    apply Notification "pagerduty-host" to Host {
      command = "notify-host-by-pagerduty"
      states = [ Up, Down ]
      types = [ Problem, Acknowledgement, Recovery ]
      period = "24x7"
      users = [ "pagerduty" ]

      assign where host.vars.enable_pagerduty == true
    }
    }
  | PAGERDUTY

  file { '/etc/icinga2/features-enabled/pagerduty-icinga2.conf':
    ensure  => 'present',
    content => $pagerduty_conf,
    mode    => '0640',
    owner   => 'icinga',
    group   => 'icinga',
  }
}

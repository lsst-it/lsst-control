# @summary
#   Common functionality needed by standard nodes.
class profile::core::common {
  include timezone
  include tuned
  include chrony
  include selinux
  include firewall
  include irqbalance
  include sysstat
  include epel
  include sudo
  include accounts
  include puppet_agent
  include resolv_conf
  include ssh
  include easy_ipa
  include augeas
  include rsyslog
  include rsyslog::config
  include profile::core::telegraf
}

# @summary
#   Common functionality needed by standard nodes.
#
# @param collect_metrics
#   Enable or disable metrics collection. Metrics collection may be disabled on development
#   nodes, nodes that don't have uptime requirements, or nodes that should only have minimal
#   software load.
class profile::core::common(
  Boolean $collect_metrics = true,
) {
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
  include profile::core::hardware

  if $collect_metrics {
    include profile::core::telegraf
  }
}

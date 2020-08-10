# @summary
#   Common functionality needed by standard nodes.
#
# @param deploy_icinga_agent
#   Enables or disable the installation of icinga agent on the node
#
class profile::core::common (
  Boolean $deploy_icinga_agent = false,
){
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
  include profile::core::dielibwrapdie

  if $deploy_icinga_agent {
    include profile::core::icinga_agent
  }
}

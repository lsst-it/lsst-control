# @summary
#   Common functionality needed by standard nodes.
#
# @param deploy_icinga_agent
#   Enables or disable the installation of icinga agent on the node
#
# @param manage_puppet_agent
#   Whether or not to include the puppet_agent class
class profile::core::common (
  Boolean $deploy_icinga_agent = false,
  Boolean $manage_puppet_agent = true,
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

  if $manage_puppet_agent {
    include puppet_agent
  }
}

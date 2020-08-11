# @summary
#   Common functionality needed by standard nodes.
#
# @param deploy_icinga_agent
#   Enables or disable the installation of icinga agent on the node
#
# @param manage_puppet_agent
#   Whether or not to include the puppet_agent class
#
# @param chrony
#   Enable or disable inclusion of the chrony class.  There are a few special
#   situations in which ntpd needs to be used instead of chrony (such as
#   perfsonar nodes).
#
class profile::core::common (
  Boolean $deploy_icinga_agent = false,
  Boolean $manage_puppet_agent = true,
  Boolean $manage_chrony = true,
){
  include accounts
  include augeas
  include easy_ipa
  include epel
  include firewall
  include irqbalance
  include profile::core::dielibwrapdie
  include profile::core::hardware
  include resolv_conf
  include rsyslog
  include rsyslog::config
  include selinux
  include ssh
  include sudo
  include sysstat
  include timezone
  include tuned

  if $deploy_icinga_agent {
    include profile::core::icinga_agent
  }

  if $manage_puppet_agent {
    include puppet_agent
  }

  if $manage_chrony {
    include chrony
  }
}

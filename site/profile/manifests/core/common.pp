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
# @param manage_sssd
#   Enable or disable management of `/etc/sssd/sssd.conf`
#
# @param manage_krb5
#   Enable or disable management of `/etc/krb5.conf`
#
# @param manage_ldap
#   Enable or disable management of openldap ipa client config
#
# @param manage_ipa
#   Enable or disable management of `/etc/ipa/default.conf`
#
class profile::core::common(
  Boolean $deploy_icinga_agent = false,
  Boolean $manage_puppet_agent = true,
  Boolean $manage_chrony = true,
  Boolean $manage_sssd = true,
  Boolean $manage_krb5 = true,
  Boolean $manage_ldap = true,
  Boolean $manage_ipa = true,
) {
  include accounts
  include augeas
  include easy_ipa
  include epel
  include firewall
  include irqbalance
  include network
  include profile::core::dielibwrapdie
  include profile::core::hardware
  include profile::core::ipa
  include profile::core::selinux
  include resolv_conf
  include rsyslog
  include rsyslog::config
  include selinux
  include ssh
  include sudo
  include sysctl::values
  include sysstat
  include timezone
  include tuned

  if $deploy_icinga_agent {
    include profile::icinga::agent
  }

  if $manage_puppet_agent {
    include puppet_agent
  }

  if $manage_chrony {
    include chrony
  }

  if $manage_sssd {
    include sssd
    # run ipa-install-* script before trying to managing sssd.conf
    Class[easy_ipa] -> Class[sssd]
  }

  if $manage_krb5 {
    include mit_krb5
    # run ipa-install-* script before trying to managing krb5.conf
    Class[easy_ipa] -> Class[mit_krb5]
  }

  if $manage_ldap {
    include openldap::client
    # run ipa-install-* script before trying to managing openldap
    Class[easy_ipa] -> Class[openldap::client]
  }

  if $manage_ipa {
    include profile::core::ipa
    Class[easy_ipa] -> Class[profile::core::ipa]
  }
}

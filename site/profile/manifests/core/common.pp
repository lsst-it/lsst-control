# @summary
#   Common functionality needed by standard nodes.
#
# @param deploy_icinga_agent
#   Enables or disable the installation of icinga agent on the node
#
# @param manage_puppet_agent
#   Whether or not to include the puppet_agent class
#
# @param manage_chrony
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
# @param disable_ipv6
#   If `true`, disable ipv6 networking support. This parameter is intended to eventually
#   replace the direct inclusion of the `profile::core::sysctl::disable_ipv6` class.
#
# @param manage_firewall
#   Whether or not to include the firewall class
#
# @param install_telegraf
#   If `true`, manage telegraf
#
# @param manage_powertop
#   If `true`, manage powertop service
#
# @param manage_scl
#   If `true`, enable redhat scl repos
#
# @param manage_repos
#   If `true`, manage core os yum repos
#
# @param manage_lldp
#   If `true`, manage lldp
#
# @param manage_irqbalance
#   If `true`, manage irqbalance
#
class profile::core::common (
  Boolean $deploy_icinga_agent = false,
  Boolean $manage_puppet_agent = true,
  Boolean $manage_chrony = true,
  Boolean $manage_sssd = true,
  Boolean $manage_krb5 = true,
  Boolean $manage_ldap = true,
  Boolean $manage_ipa = true,
  Boolean $disable_ipv6 = false,
  Boolean $manage_firewall = true,
  Boolean $install_telegraf = true,
  Boolean $manage_powertop = false,
  Boolean $manage_scl = true,
  Boolean $manage_repos = true,
  Boolean $manage_lldp = true,
  Boolean $manage_irqbalance = true,
) {
  include accounts
  include augeas
  include easy_ipa
  include epel
  include hosts
  include network
  include profile::core::ca
  include profile::core::dielibwrapdie
  include profile::core::ifdown
  include profile::core::ipa
  include profile::core::k5login
  include profile::core::kernel
  include profile::core::nm_dispatch
  include profile::core::selinux
  include profile::core::systemd
  include profile::core::yum
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

  if $facts['os']['name'] == 'CentOS' {
    if $manage_repos {
      include profile::core::yum::centos

      resources { 'yumrepo':
        purge => true,
      }
    }
  }

  if $manage_irqbalance {
    include irqbalance
  }

  if $deploy_icinga_agent {
    include profile::icinga::agent
  }

  if $install_telegraf {
    include profile::core::monitoring
  }

  if $manage_firewall {
    include firewall
    Class[easy_ipa] -> Class[firewall]
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

  if $disable_ipv6 {
    include profile::core::sysctl::disable_ipv6
  }

  if $manage_powertop {
    include profile::core::powertop
  }

  if $facts['os']['architecture'] == 'x86_64' {
    # no scl repos for aarch64
    if $manage_scl {
      include scl
    }
  }
  if $manage_lldp {
    class { 'lldpd':
      manage_repo => true,
    }
  }
  unless $facts['is_virtual'] {
    include profile::core::hardware
  }

  ensure_resource('service', 'NetworkManager', {
      ensure => running,
      enable => true,
  })
}

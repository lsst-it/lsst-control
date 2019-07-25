class profile::comcam::common {
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

  # XXX write some glue code and move this to hiera -JCH
  sshd_config { "PermitRootLogin":
    ensure => present,
    value  => "without-password",
  }
  sshd_config { "PasswordAuthentication":
    ensure => present,
    value  => "no",
  }
  sshd_config { "PrintMotd":
    ensure => present,
    value  => "no",
  }
  sshd_config { "UseDNS":
    ensure => present,
    value  => "no",
  }
}

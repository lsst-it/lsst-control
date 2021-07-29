class profile::core::perfsonar {
  include epel
  include profile::core::letsencrypt
  include augeas  # needed by perfsonar

  $fqdn    = $facts['networking']['fqdn']
  $le_root = "/etc/letsencrypt/live/${fqdn}"

  letsencrypt::certonly { $fqdn:
    plugin      => 'dns-route53',
    manage_cron => true,
  }
  -> class { '::perfsonar':
    manage_apache      => true,
    remove_root_prompt => true,
    manage_epel        => false,
    ssl_cert           => "${le_root}/cert.pem",
    ssl_chain_file     => "${le_root}/fullchain.pem",
    ssl_key            => "${le_root}/privkey.pem",
    require            => Class['epel'],
  }

  # perfsonar-toolkit pulls in perfsonar-toolkit-systemenv-testpoint which pulls in yum-cron
  service { 'yum-cron':
    ensure => 'stopped',
    enable => false,
  }
}

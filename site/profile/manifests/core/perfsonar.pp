class profile::core::perfsonar {
  include profile::core::letsencrypt

  $fqdn    = $facts['fqdn']
  $le_root = "/etc/letsencrypt/live/${fqdn}"

  letsencrypt::certonly { $fqdn:
    plugin      => 'dns-route53',
    manage_cron => true,
  }

  class { '::perfsonar':
    manage_apache      => true,
    remove_root_prompt => true,
    ssl_cert           => "${le_root}/cert.pem",
    ssl_chain_file     => "${le_root}/fullchain.pem",
    ssl_key            => "${le_root}/privkey.pem",
  }
}

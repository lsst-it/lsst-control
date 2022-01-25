# @summary
#   So far, just to generate signed ipam ssl certificate

class profile::core::ipam {
  include profile::core::letsencrypt

  $fqdn = $facts[fqdn]
  $le_root = "/etc/letsencrypt/live/${fqdn}"

  #  Generate and sign certificate
  letsencrypt::certonly { $fqdn:
    plugin      => 'dns-route53',
    manage_cron => true,
  }
}

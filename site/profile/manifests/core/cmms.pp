# @summary
#   Load letsencrypt into cmms apache
#

class profile::core::cmms (
) {
  include profile::core::letsencrypt

  $fqdn  = fact('networking.fqdn')

  #  Letsencrypt cert path
  $le_root = "/etc/letsencrypt/live/${fqdn}"
  $old_cert = '/etc/apache2/ssl/appliance/appliance.openmaint.org'
  $new_certs = '/opt/new_certs.sh'
  $cert_default_path = '/etc/apache2/sites-available'
  $replace_certs = @("CERTS")
    #!/usr/bin/bash
    sed -i 's,${old_cert}.crt,${le_root}/fullchain.pem,g' ${cert_default_path}/openmaint_default.conf
    sed -i 's,${old_cert}.key,${le_root}/privkey.pem,g' ${cert_default_path}/openmaint_default.conf
    |CERTS

  letsencrypt::certonly { $fqdn:
    plugin      => 'dns-route53',
    manage_cron => true,
  }
  file { $new_certs:
    ensure  => file,
    mode    => '0755',
    content => $replace_certs,
  }
  -> exec { $new_certs:
    cwd      => '/var/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    unless   => "grep privkey ${cert_default_path}/openmaint_default.conf",
    notify   => Service['apache2'],
  }

  service { 'apache2':
    ensure => 'running',
    enable => true,
  }
}

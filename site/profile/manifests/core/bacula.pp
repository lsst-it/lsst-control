# @summary
#   Provides Signed Certificate and manages HTTPD for Bacula
#

class profile::core::bacula (
) {
  include profile::core::letsencrypt
  include cron
  $packages = [
    'mod_ssl',
    'vim',
  ]
  $fqdn = $facts[fqdn]
  $bacula_root = '/opt/bacula'
  $bacula_web = '/opt/bweb/etc'
  $bacula_crt = "${bacula_root}/etc/conf.d/ssl/certs"
  $le_root = "/etc/letsencrypt/live/${fqdn}"

  $ssl_config = @("SSLCONF"/$)
    server.modules += ("mod_openssl")
    \$SERVER["socket"] == "0.0.0.0:443" {
        ssl.engine = "enable" 
        ssl.privkey= "${fqdn}/privkey.pem" 
        ssl.pemfile= "${fqdn}/fullchain.pem" 
    \$SERVER["socket"] == "0.0.0.0:9143" {
        ssl.engine = "enable" 
        ssl.privkey= "${fqdn}/privkey.pem" 
        ssl.pemfile= "${fqdn}/fullchain.pem" 
    \$SERVER["socket"] == "0.0.0.0:9180" {
        ssl.engine = "enable" 
        ssl.privkey= "${fqdn}/privkey.pem" 
        ssl.pemfile= "${fqdn}/fullchain.pem" 
    |SSLCONF

  #  Ensure Packages installation
  package { $packages:
    ensure => 'present',
  }

  #  Manage HTTPD Service
  service { 'httpd':
    ensure  => 'running',
    enable  => true,
    require => Package[$packages],
  }

  #  Generate and sign certificate
  letsencrypt::certonly { $fqdn:
    plugin      => 'dns-route53',
    manage_cron => true,
  }

  #  Bacula HTTPD File definition
  file { "${bacula_root}/ssl_config":
    ensure  => file,
    mode    => '0644',
    owner   => 'bacula',
    content => $ssl_config,
    notify  => Service['httpd'],
  }

  #  Enable SSL in Bacula
  exec { "cat ${bacula_root}/ssl_config >> ${bacula_web}/httpd.conf":
    cwd    => '/var/tmp/',
    path   => ['/sbin', '/usr/sbin', '/bin'],
    unless => ["grep 'fullchain.pem' ${bacula_web}/httpd.conf"],
    notify => Service['httpd'],
  }
}

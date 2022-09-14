# @summary
#   Provides Signed Certificate and manages HTTPD for Bacula
#
# @param id
#   Bacula customer Identification string
#

class profile::core::bacula (
  String $id = 'null',
) {
  include cron
  include postgresql::server
  include profile::core::letsencrypt
  include yum

  $bacula_crt = "${bacula_root}/etc/conf.d/ssl/certs"
  $bacula_root = '/opt/bacula'
  $bacula_package = 'bacula-enterprise-postgresql'
  $bacula_version = '14.0.4'
  $bacula_web = '/opt/bweb/etc'
  $packages = [
    'httpd',
    'mod_ssl',
    'vim',
  ]
  $fqdn = $facts[fqdn]
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

  file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-BACULA':
    ensure => file,
    source => "https://www.baculasystems.com/dl/${id}/BaculaSystems-Public-Signature-08-2017.asc",
  }

  yumrepo { 'bacula':
    ensure   => 'present',
    baseurl  => "https://www.baculasystems.com/dl/${id}/rpms/bin/${bacula_version}/rhel7-64/",
    descr    => 'Bacula Enterprise Repository',
    enabled  => true,
    gpgcheck => '1',
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-BACULA',
    require  => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-BACULA'],
  }

  package { $bacula_package:
    ensure  => 'present',
    require => Yumrepo['bacula'],
  }
  # #  Bacula HTTPD File definition
  # file { "${bacula_root}/ssl_config":
  #   ensure  => file,
  #   mode    => '0644',
  #   owner   => 'bacula',
  #   content => $ssl_config,
  #   notify  => Service['httpd'],
  # }

  # #  Enable SSL in Bacula
  # exec { "cat ${bacula_root}/ssl_config >> ${bacula_web}/httpd.conf":
  #   cwd    => '/var/tmp/',
  #   path   => ['/sbin', '/usr/sbin', '/bin'],
  #   unless => ["grep 'fullchain.pem' ${bacula_web}/httpd.conf"],
  #   notify => Service['httpd'],
  # }
}

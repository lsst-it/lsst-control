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

  $fqdn = $facts[fqdn]
  $le_root = "/etc/letsencrypt/live/${fqdn}"
  $bacula_init = @(BACULAINIT)
    sudo -H -u postgres bash -c '/opt/bacula/scripts/create_postgresql_database'
    sudo -H -u postgres bash -c '/opt/bacula/scripts/make_postgresql_tables'
    sudo -H -u postgres bash -c '/opt/bacula/scripts/grant_postgresql_privileges'
    |BACULAINIT
  $bacula_package = 'bacula-enterprise-postgresql'
  $bacula_port = '9180'
  $bacula_root = '/opt/bacula'
  $bacula_version = '14.0.4'
  $bacula_vsphere_plugin = 'bacula-enterprise-vsphere'
  $bacula_web = 'bacula-enterprise-bweb'
  $bacula_web_path = '/opt/bweb/etc'
  $cert_name = 'baculacert.pem'
  $bacula_crt  = "${bacula_root}/etc/conf.d/ssl/certs/"
  $httpd_conf = @("HTTPCONF")
    <VirtualHost *:80> 
    DocumentRoot "/opt/bweb/html/"
    ServerName ${fqdn}
    <Directory /opt/bweb/cgi>
        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        AllowOverride None
    </Directory>
    ScriptAlias /cgi-bin/bweb /opt/bweb/cgi
    Alias /bweb/fv /opt/bweb/spool
    <Directory "/var/spool/bweb">
        Options None
        AllowOverride AuthConfig
        Order allow,deny
        Allow from all
    </Directory>
    Alias /bweb /opt/bweb/html
    <Directory "/opt/bweb/html">
        Options None
        AllowOverride AuthConfig
        Require all granted
    </Directory>
    ErrorLog "/var/log/httpd/${fqdn}-error_log"
    CustomLog "/var/log/httpd/${fqdn}-access_log" combined
    RewriteRule "/(.*)" https://${fqdn}":9180/cgi-bin/bweb/bweb.pl/\$1" [P]
    </VirtualHost> 
    |HTTPCONF
  $packages = [
    'httpd',
    'mod_ssl',
    'vim',
  ]
  $pip_packages = [
    'pypsexec',
    'pywinrm',
    'pypsrp',
  ]
  $ssl_config = @("SSLCONF"/$)
    server.modules += ("mod_openssl")
    ssl.engine = "enable" 
    ssl.pemfile= "${bacula_crt}/${cert_name}"
    |SSLCONF

  #  Ensure Packages installation
  package { $packages:
    ensure => 'present',
  }

  #  Ensure Bacula's Python3 required packages
  package { $pip_packages:
    ensure   => 'present',
    provider => 'pip3',
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

  #  Import Licenced GPG Bacula Key
  file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-BACULA':
    ensure => file,
    source => "https://www.baculasystems.com/dl/${id}/BaculaSystems-Public-Signature-08-2017.asc",
  }

  #  Bacula Enterprise Repository
  yumrepo { 'bacula':
    ensure   => 'present',
    baseurl  => "https://www.baculasystems.com/dl/${id}/rpms/bin/${bacula_version}/rhel7-64/",
    descr    => 'Bacula Enterprise Repository',
    enabled  => true,
    gpgcheck => '1',
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-BACULA',
    require  => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-BACULA'],
  }

  #  BWeb Repository
  yumrepo { 'bacula-bweb':
    ensure   => 'present',
    baseurl  => "https://www.baculasystems.com/dl/${id}/rpms/bweb/${bacula_version}/rhel7-64/",
    descr    => 'Bacula Web Repository',
    enabled  => true,
    gpgcheck => '0',
  }

  #  Bacula DAG Repository
  yumrepo { 'bacula-dag':
    ensure   => 'present',
    baseurl  => 'https://www.baculasystems.com/dl/DAG/rhel7-64/',
    descr    => 'Bacula DAG Repository',
    enabled  => true,
    gpgcheck => '0',
  }

  #  Bacula vSphere Plugin Repository
  yumrepo { 'bacula-vsphere':
    ensure   => 'present',
    baseurl  => "https://www.baculasystems.com/dl/${id}/rpms/vsphere/${bacula_version}/rhel7-64/",
    descr    => 'Bacula DAG Repository',
    enabled  => true,
    gpgcheck => '0',
  }

  #  Install Bacula Enterprise
  package { $bacula_package:
    ensure  => 'present',
    require => Yumrepo['bacula'],
  }

  #  Install Bacula BWeb
  package { $bacula_web:
    ensure  => 'present',
    require => Yumrepo['bacula-bweb'],
  }

  #  Install Bacula vSphere Plugin
  package { $bacula_vsphere_plugin:
    ensure  => 'present',
    require => Yumrepo['bacula-vsphere'],
  }

  #  Initialize Postgres Bacula DB
  exec { $bacula_init:
    cwd     => $bacula_root,
    path    => ['/sbin', '/usr/sbin', '/bin'],
    unless  => "sudo -H -u postgres bash -c 'psql -l' | grep bacula",
    require => Package[$bacula_package],
  }

  #  Run and enable Bacula Daemons
  service { 'bacula-fd':
    ensure  => 'running',
    enable  => true,
    require => Package[$bacula_package],
  }
  service { 'bacula-sd':
    ensure  => 'running',
    enable  => true,
    require => Package[$bacula_package],
  }
  service { 'bacula-dir':
    ensure  => 'running',
    enable  => true,
    require => Package[$bacula_package],
  }

  #  Run and Enable BWeb
  service { 'bweb':
    ensure  => 'running',
    enable  => true,
    require => Package[$bacula_web],
  }

  #  Provision bweb tables to psql
  exec { 'bash /opt/bweb/bin/install_bweb.sh':
    cwd     => '/var/tmp/',
    path    => ['/sbin', '/usr/sbin', '/bin'],
    require => Package[$bacula_web],
    unless  => 'sudo -H -u postgres bash -c \'psql -U postgres -d bacula -E -c "\dt"\' | grep bweb',
  }

  #  Bacula HTTPD File definition
  file { "${bacula_root}/ssl_config":
    ensure  => file,
    content => $ssl_config,
    owner   => 'bacula',
    mode    => '0644',
    notify  => Service['httpd'],
    require => Package[$bacula_web],
  }

  #  HTTPD File definition
  file { '/etc/httpd/conf.d/bweb.conf':
    ensure  => file,
    mode    => '0644',
    content => $httpd_conf,
    notify  => Service['httpd'],
  }

  #  Change PrivateKey mode
  cron::job { 'baculacert':
    ensure      => present,
    minute      => '0',
    hour        => '0',
    date        => '*/1',
    month       => '*',
    weekday     => '*',
    command     => "cat ${le_root}/privkey.pem <(echo) ${le_root}/cert.pem > ${bacula_crt}/${cert_name}",
    description => 'Combined Cert for Bacula Web',
    require     => Package[$bacula_web],
    notify      => Service['bweb'],
  }

  #  Enable SSL in Bacula
  exec { "cat ${bacula_root}/ssl_config >> ${bacula_web_path}/httpd.conf":
    cwd     => '/var/tmp/',
    notify  => Service['httpd'],
    path    => ['/sbin', '/usr/sbin', '/bin'],
    require => Package[$bacula_web],
    unless  => ["grep '${cert_name}' ${bacula_web_path}/httpd.conf"],
  }
}

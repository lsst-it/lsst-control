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
  $bacula_init = @(BACULAINIT)
    sudo -H -u postgres bash -c '/opt/bacula/scripts/create_postgresql_database'
    sudo -H -u postgres bash -c '/opt/bacula/scripts/make_postgresql_tables'
    sudo -H -u postgres bash -c '/opt/bacula/scripts/grant_postgresql_privileges'
    |BACULAINIT
  $bacula_package = 'bacula-enterprise-postgresql'
  $bacula_root = '/opt/bacula'
  $bacula_version = '14.0.4'
  $bacula_web = 'bacula-enterprise-bweb'
  $bacula_web_path = '/opt/bweb/etc'
  $fqdn = $facts[fqdn]
  $httpd_conf = @("HTTPCONF")
    <VirtualHost *:80> 
      DocumentRoot "/var/www/html"    
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
    </VirtualHost>
    <VirtualHost *:443> 
      DocumentRoot "/var/www/html"    
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
      SSLEngine on  
      SSLCertificateFile /etc/letsencrypt/live/${fqdn}/cert.pem 
      SSLCertificateKeyFile /etc/letsencrypt/live/${fqdn}/privkey.pem
      ErrorLog "/var/log/httpd/${fqdn}-error_log"
      CustomLog "/var/log/httpd/${fqdn}-access_log" combined
     </VirtualHost>
    |HTTPCONF
  $le_root = "/etc/letsencrypt/live/${fqdn}"
  $packages = [
    'httpd',
    'mod_ssl',
    'vim',
  ]
  $ssl_config = @("SSLCONF"/$)
    server.modules += ("mod_openssl")
    \$SERVER["socket"] == "0.0.0.0:443" {
        ssl.engine = "enable" 
        ssl.privkey= "${le_root}/privkey.pem" 
        ssl.pemfile= "${le_root}/fullchain.pem"
    }
    \$SERVER["socket"] == "0.0.0.0:9143" {
        ssl.engine = "enable" 
        ssl.privkey= "${le_root}/privkey.pem" 
        ssl.pemfile= "${le_root}/fullchain.pem" 
    }
    \$SERVER["socket"] == "0.0.0.0:9180" {
        ssl.engine = "enable" 
        ssl.privkey= "${le_root}/privkey.pem" 
        ssl.pemfile= "${le_root}/fullchain.pem" 
    }
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

  #  Enable SSL in Bacula
  exec { "cat ${bacula_root}/ssl_config >> ${bacula_web_path}/httpd.conf":
    cwd     => '/var/tmp/',
    notify  => Service['httpd'],
    path    => ['/sbin', '/usr/sbin', '/bin'],
    require => Package[$bacula_web],
    unless  => ["grep 'fullchain.pem' ${bacula_web_path}/httpd.conf"],
  }
}

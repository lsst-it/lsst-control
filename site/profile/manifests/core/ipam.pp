# @summary
#   Provides Signed Certificate, Mysql Configuration, and PHP for phpIPAM
#
# @param password
#   MySQL Backup Password
#
# @param database
#   phpIPAM database name
#
class profile::core::ipam (
  String[1] $database,
  Sensitive[String[1]] $password,
) {
  include profile::core::letsencrypt

  $mariadb_packages = [
    'mariadb-libs-5.5.68-1.el7.x86_64',
    'mariadb-server-5.5.68-1.el7.x86_64',
    'mariadb-5.5.68-1.el7.x86_64',
  ]

  $packages = [
    'httpd',
    'php',
    'php-cli',
    'php-gd',
    'php-common',
    'php-ldap',
    'php-pdo',
    'php-pear',
    'php-snmp',
    'php-xml',
    'php-mysql',
    'php-mbstring',
    'git',
    'mod_ssl',
  ]

  $fqdn = fact('networking.fqdn')
  $le_root = "/etc/letsencrypt/live/${fqdn}"
  $my_cnf_master = @("MYCNF")
    [mysqld]
    datadir=/var/lib/mysql
    socket=/var/lib/mysql/mysql.sock
    symbolic-links=0
    server-id = 1
    binlog-do-db = ${database}
    replicate-do-db = ${database}
    relay-log = mysql-relay-bin
    relay-log-index = mysql-relay-bin.index
    log-bin = mysql-bin

    [mysqldump]
    user = backup 
    password = ${password}

    [mysqld_safe]
    log-error=/var/log/mariadb/mariadb.log
    pid-file=/var/run/mariadb/mariadb.pid

    !includedir /etc/my.cnf.d
    |MYCNF

  $my_cnf_slave = @("MYCNF")
    [mysqld]
    datadir=/var/lib/mysql
    socket=/var/lib/mysql/mysql.sock
    symbolic-links=0
    server-id = 2
    binlog-do-db = ${database}
    replicate-do-db = ${database}
    relay-log = mysql-relay-bin
    relay-log-index = mysql-relay-bin.index
    log-bin = mysql-bin

    [mysqldump]
    user = backup 
    password = ${password}

    [mysqld_safe]
    log-error=/var/log/mariadb/mariadb.log
    pid-file=/var/run/mariadb/mariadb.pid

    !includedir /etc/my.cnf.d
    |MYCNF

  $httpd_conf = @("HTTPCONF")
    <VirtualHost *:80>
        DocumentRoot "/var/www/html"
        ServerName ${fqdn}
        <Directory "/var/www/html">
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
        </Directory>
        ErrorLog "/var/log/phpipam-error_log"
        CustomLog "/var/log/phpipam-access_log" combined
        Redirect permanent / https://${fqdn}/
    </VirtualHost>

    <VirtualHost *:443>    
        DocumentRoot "/var/www/html"    
        ServerName ${fqdn}    
        <Directory "/var/www/html">        
            Options Indexes FollowSymLinks        
            AllowOverride All        
            Require all granted    
        </Directory>  
        SSLEngine on  
        SSLCertificateFile /etc/letsencrypt/live/${fqdn}/cert.pem 
        SSLCertificateKeyFile /etc/letsencrypt/live/${fqdn}/privkey.pem 
        ErrorLog "/var/log/phpipam-error_log"
        CustomLog "/var/log/phpipam-access_log" combined
    </VirtualHost>
    |HTTPCONF

  #  Generate and sign certificate
  letsencrypt::certonly { $fqdn:
    plugin      => 'dns-route53',
    manage_cron => true,
  }
  service { 'mariadb':
    ensure  => 'running',
    enable  => true,
    require => Package[$mariadb_packages],
  }
  service { 'httpd':
    ensure  => 'running',
    enable  => true,
    require => Package[$packages],
  }

  #  MySQL configuration file definition
  if $fqdn == 'ipam.cp.lsst.org' {
    file { '/etc/my.cnf':
      ensure  => file,
      mode    => '0644',
      content => $my_cnf_master,
      notify  => Service['mariadb'],
    }
  }
  else {
    file { '/etc/my.cnf':
      ensure  => file,
      mode    => '0644',
      content => $my_cnf_slave,
      notify  => Service['mariadb'],
    }
  }

  #  Packages installation
  ensure_packages($mariadb_packages)
  ensure_packages($packages)

  #  HTTPD File definition
  file { '/etc/httpd/conf.d/ipam.conf':
    ensure  => file,
    mode    => '0644',
    content => $httpd_conf,
    require => Package[$packages],
    notify  => Service['httpd'],
  }

  #  PHP Timezone
  exec { "sed -i 's,^;date.timezone.*$,date.timezone = America/Santiago,g' /etc/php.ini":
    cwd      => '/var/tmp/',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => 'grep Santiago /etc/php.ini',
    loglevel => debug,
    require  => Package[$packages],
    notify   => Service['httpd'],
  }
}

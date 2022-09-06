# @summary
#   So far, just to generate signed ipam ssl certificate

class profile::core::ipam (
  String $password,
){
  include profile::core::letsencrypt

  $mariadb_packages = [
    'mariadb-libs-5.5.68-1.el7.x86_64',
    'mariadb-server-5.5.68-1.el7.x86_64',
    'mariadb-5.5.68-1.el7.x86_64',
  ]

  $fqdn = $facts[fqdn]
  $le_root = "/etc/letsencrypt/live/${fqdn}"
  $my_cnf_master = @("MYCNF")
    [mysqld]
    datadir=/var/lib/mysql
    socket=/var/lib/mysql/mysql.sock
    symbolic-links=0
    server-id = 1
    binlog-do-db=database
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
    replicate-do-db=database
    relay-log = mysql-relay-bin
    log-bin = mysql-bin

    [mysqldump]
    user = backup 
    password = ${password}

    [mysqld_safe]
    log-error=/var/log/mariadb/mariadb.log
    pid-file=/var/run/mariadb/mariadb.pid

    !includedir /etc/my.cnf.d
    |MYCNF
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

  if $fqdn == 'ipam.cp.lsst.org' {
    file { '/etc/my.cnf':
      ensure  => file,
      mode    => '0644',
      content => $my_cnf_master,
      require => Service['mariadb'],
      notify  => Service['mariadb'],
    }
  }
  else {
    file { '/etc/my.cnf':
      ensure  => file,
      mode    => '0644',
      content => $my_cnf_slave,
      require => Service['mariadb'],
      notify  => Service['mariadb'],
    }
  }
}

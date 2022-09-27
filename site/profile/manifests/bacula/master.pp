# @summary
#   Provides Signed Certificate and manages HTTPD for Bacula
#
# @param id
#   Bacula customer Identification string
#
# @param ipa_server
#   IPA Server to bind
#
# @param email
#   Email support
#
# @param passwd
#   Bacula Service Account Password for LDAP Binding
#
# @param user
#   Bacula Service Account User
#
# @param ssh_pub_key
#   User's ssh private key
#
# @param ssh_priv_key
#   User's ssh public key
class profile::bacula::master (
  String $id = 'null',
  String $ipa_server = 'null',
  String $email = 'null',
  String $passwd = 'null',
  String $user = 'null',
  String $ssh_priv_key = 'null',
  String $ssh_pub_key = 'null',
) {
  include cron
  include postgresql::server
  include profile::core::letsencrypt
  include yum

  $fqdn = $facts[fqdn]
  $le_root = "/etc/letsencrypt/live/${fqdn}"
  $opt = '/opt'
  $admin_script = "${opt}/get_admins.sh"
  $bacula_root = "${opt}/bacula"
  $bacula_init = @("BACULAINIT")
    sudo -H -u postgres bash -c '${bacula_root}/scripts/create_postgresql_database'
    sudo -H -u postgres bash -c '${bacula_root}/scripts/make_postgresql_tables'
    sudo -H -u postgres bash -c '${bacula_root}/scripts/grant_postgresql_privileges'
    |BACULAINIT
  $bacula_package = 'bacula-enterprise-postgresql'
  $bacula_port = '9180'
  $bacula_version = '14.0.4'
  $bacula_vsphere_plugin = 'bacula-enterprise-vsphere'
  $bacula_web = 'bacula-enterprise-bweb'
  $bacula_web_root = "${opt}/bweb"
  $bacula_web_etc = "${bacula_web_root}/etc"
  $cert_name = 'baculacert.pem'
  $bacula_crt  = "${bacula_root}/etc/conf.d/ssl/certs"
  $base_dn = 'dc=lsst,dc=cloud'
  $subfilter_dn = "cn=users,cn=accounts,${base_dn}"
  $httpd_conf = @("HTTPCONF")
    <VirtualHost *:80> 
    DocumentRoot "${bacula_web_root}/html/"
    ServerName ${fqdn}
    <Directory ${bacula_web_root}/cgi>
        Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
        AllowOverride None
    </Directory>
    ScriptAlias /cgi-bin/bweb ${bacula_web_root}/cgi
    Alias /bweb/fv ${bacula_web_root}/spool
    <Directory "/var/spool/bweb">
        Options None
        AllowOverride AuthConfig
        Order allow,deny
        Allow from all
    </Directory>
    Alias /bweb ${bacula_web_root}/html
    <Directory "${bacula_web_root}/html">
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
    'openldap-clients',
  ]
  $pip_packages = [
    'pypsexec',
    'pywinrm',
    'pypsrp',
  ]
  $ssl_config = @("SSLCONF"/$)
    server.port = 9180
    var.basedir = env.BWEBBASE
    var.logdir = env.BWEBLOG
    server.modules = ("mod_auth", "mod_cgi", "mod_alias", "mod_setenv", "mod_accesslog", "mod_openssl", "mod_authn_ldap")
    server.document-root = basedir + "/html/" 
    server.breakagelog = logdir + "/bweb-error.log"
    server.pid-file = logdir + "/bweb.pid" 
    cgi.assign = ( ".pl" => "/usr/bin/perl" )
    alias.url = ( "/cgi-bin/bweb/" => basedir + "/cgi/", "/bweb/fv/" => "${bacula_web_root}/spool/","/bweb" => basedir + "/html/", )
    setenv.add-environment = (
      "PATH" => env.PATH,
      "PERLLIB" => basedir + "/lib/",
      "BWEBCONF" => basedir + "/bweb.conf",
      "BWEBSESSION" => logdir + "/bweb/"
    )
    index-file.names = ( "index.html" )
    mimetype.assign = (
    ".html" => "text/html",
    ".gif" => "image/gif",
    ".jpeg" => "image/jpeg",
    ".jpg" => "image/jpeg",
    ".png" => "image/png",
    ".ico" => "image/x-icon",
    ".css" => "text/css",
    ".json" => "text/plain",
    ".js" => "application/javascript",
    ".svg" => "image/svg+xml",
    )
    server.username  = "bacula"
    server.groupname = "bacula"
    ssl.engine = "enable" 
    ssl.pemfile= "${bacula_crt}/${cert_name}"
    auth.backend = "ldap"
    auth.backend.ldap.hostname = "${ipa_server}"
    auth.backend.ldap.base-dn = "${subfilter_dn}"
    auth.backend.ldap.filter = "(uid=$)"
    auth.backend.ldap.bind-dn = "uid=${user},${subfilter_dn}"
    auth.backend.ldap.bind-pw = "${passwd}"
    auth.backend.ldap.allow-empty-pw = "disable"
    |SSLCONF
  $bweb_conf = @("BWEBCONF"/$)
    \$VAR1 = {
          'enable_security' => 0,
          'nb_grouping_separator' => 'on',
          'size_unit' => 'Bi',
          'enable_web_bconsole' => 0,
          'enable_system_auth' => 'on',
          'subconf' => {},
          'enable_self_user_restore' => 0,
          'password' => '',
          'customer_id' => '',
          'dbi' => 'DBI:Pg:database=bacula',
          'workset_dir' => '${bacula_root}/working/conf.d',
          'debug' => 0,
          'user' => 'bacula',
          'config_dir' => '${bacula_root}/etc/conf.d',
          'html_dir' => '${bacula_web_root}/html',
          'stat_job_table' => 'JobHisto',
          'display_log_time' => 'on',
          'lang' => 'en',
          'wiki_url' => '',
          'rows_per_page' => '20',
          'description' => undef,
          'bconsole' => '${bacula_root}/bin/bconsole -n -c ${bacula_root}/etc/bconsole.conf',
          'hide_bconfig_menu_item' => 0,
          'fv_write_path' => '${bacula_web_root}/spool',
          'template_dir' => '${bacula_web_root}/tpl',
          'enable_security_acl' => 0,
          'email_media' => '${email}',
          'default_age' => '7d',
          'ssl_dir' => '${bacula_root}/etc/conf.d/ssl',
          'default_limit' => '100'
        };
    |BWEBCONF
  $admin_search = "(ldapsearch -H \"ldap://${ipa_server}\" -b \"${base_dn}\" -D \"uid=${user},${subfilter_dn}\" -w \"${passwd}\" \"(&(objectClass=inetOrgPerson)(memberOf=cn=admins,cn=groups,cn=accounts,${base_dn}))\" | grep 'dn: uid' | awk '{print substr(\$2,5)}' | sed 's/,${subfilter_dn}//g')"
  $process_admin = @("PROCESS"/$)
    #!/usr/bin/env bash
    readarray -t admins < <${admin_search}
    lenght=\$((\${#admins[@]}-1))
    i=0
    until [ \$i -gt \${lenght} ]
    do
      psql -U postgres -d bacula -c "insert into bweb_user(userid,username,use_acl,enabled,comment,passwd,tpl) values ('\$((\${i}+1))','\${admins[\$i]}','f','t','IT','systemauth','en');"
      for j in {1..24}
      do
         psql -U postgres -d bacula -c "insert into bweb_role_member values (\${j},\$((\${i}+1)));"
      done
      ((i++))
    done
    |PROCESS

  file { $admin_script:
    ensure  => file,
    mode    => '0755',
    content => $process_admin,
  }

  #  Populate BWeb with Admin IPA Users
  exec { "sudo -H -u postgres bash -c ${opt}/get_admins.sh":
    cwd     => '/var/tmp/',
    path    => ['/sbin', '/usr/sbin', '/bin'],
    unless  => "sudo -H -u postgres bash -c 'psql -U postgres -d bacula -E -c \"select * from bweb_user\"' | grep ${user}",
    require => File[$admin_script],
  }
  #  Ensure Packages installation
  package { $packages:
    ensure => 'present',
  }

  #  Ensure Bacula's Python3 required packages
  exec { 'python3 -m pip install --upgrade pip==21.3.1':
    cwd     => '/var/tmp/',
    path    => ['/sbin', '/usr/sbin', '/bin'],
    unless  => 'pip3 --version | grep 21.3.1',
    require => File[$admin_script],
  }
  ->package { $pip_packages:
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
  exec { "sudo bash ${bacula_web_root}/bin/install_bweb.sh":
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

  # #  HTTPD File definition
  # file { '/etc/httpd/conf.d/bweb.conf':
  #   ensure  => file,
  #   mode    => '0644',
  #   content => $httpd_conf,
  #   notify  => Service['httpd'],
  # }

  #  Manage Bacula Web httpd.conf
  file { "${bacula_web_etc}/httpd.conf":
    ensure  => file,
    mode    => '0644',
    notify  => Service['bweb'],
    require => Package[$bacula_web],
    content => $ssl_config,
  }

  #  Manage Bacula Web bweb.conf
  file { "${bacula_web_etc}/bweb.conf":
    ensure  => file,
    mode    => '0640',
    owner   => 'bacula',
    group   => 'bacula',
    notify  => Service['bweb'],
    require => Package[$bacula_web],
    content => $bweb_conf,
  }

  #  BSys_report Generation
  archive { '/var/tmp/bsys_report.tar.gz':
    source       => 'http://www.baculasystems.com/ml/bsys_report/bsys_report.tar.gz',
    extract      => true,
    extract_path => $opt,
    user         => 'root',
    group        => 'root',
  }

  file { [ "${bacula_root}/etc/conf.d/ssl", "${bacula_root}/etc/conf.d/ssl/certs", ]:
    ensure  => directory,
    recurse => true,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0644',
  }
  #  Run the first run to get the certificated
  -> exec { "cat ${le_root}/privkey.pem <(echo) ${le_root}/cert.pem > ${bacula_crt}/${cert_name}":
    cwd    => '/var/tmp/',
    path   => ['/sbin', '/usr/sbin', '/bin'],
    onlyif => "test -f ${bacula_root}/etc/conf.d/ssl/certs/baculacert.pem",
  }
  #  Change PrivateKey mode every month
  -> cron::job { 'baculacert':
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
  -> file { "${bacula_web_etc}}/conf.d/ssl/ssh/svc_bacula_key":
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0600',
    content => $ssh_priv_key,
  }
  ->  file { "${bacula_web_etc}/conf.d/ssl/ssh/svc_bacula_key_pub.pem":
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0644',
    content => $ssh_pub_key,
  }

}

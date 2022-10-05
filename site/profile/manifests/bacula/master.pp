# @summary
#   Deploy Bacula Director, and required elements
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
#
# @param aws_hostname
#   S3 hostname
#
# @param aws_access_key
#   S3 Access Key
#
# @param aws_secret_key
#   S3 Secret Key
#
# @param aws_bucket
#   S3 Bucket Name
#
# @param bacula_pwd
#   Bacula Enrollment Password
#
# @param version
#   Bacula Version

class profile::bacula::master (
  String $id = 'null',
  String $ipa_server = 'null',
  String $email = 'null',
  String $passwd = 'null',
  String $user = 'null',
  String $ssh_priv_key = 'null',
  String $ssh_pub_key = 'null',
  String $aws_hostname = 'null',
  String $aws_access_key = 'null',
  String $aws_secret_key = 'null',
  String $aws_bucket = 'null',
  String $bacula_pwd = 'null',
  String $version = 'null',
) {
  include cron
  include postgresql::server
  include profile::core::letsencrypt
  include yum

  ##########################
  #  Variables and heredocs
  ##########################
  $fqdn = $facts[fqdn]
  $le_root = "/etc/letsencrypt/live/${fqdn}"
  $opt = '/opt'
  $scripts_dir = "${opt}/scripts"
  $bacula_root = "${opt}/bacula"
  $admin_script = "${scripts_dir}/get_admins.sh"
  $bacula_package = 'bacula-enterprise-postgresql'
  $bacula_port = '9180'
  $bacula_vsphere_plugin = 'bacula-enterprise-vsphere'
  $bacula_cloud_plugin = [
    'bacula-enterprise-cloud-storage-common',
    'bacula-enterprise-cloud-storage-s3',
  ]
  $bacula_web = 'bacula-enterprise-bweb'
  $bacula_web_root = "${opt}/bweb"
  $bacula_web_etc = "${bacula_web_root}/etc"
  $cert_name = 'baculacert.pem'
  $bacula_etc = "${bacula_root}/etc"
  $bacula_ssl  = "${bacula_etc}/conf.d/ssl"
  $bacula_crt  = "${bacula_ssl}/certs"
  $base_dn = 'dc=lsst,dc=cloud'
  $subfilter_dn = "cn=users,cn=accounts,${base_dn}"
  $admin_search = "(ldapsearch -H \"ldap://${ipa_server}\" -b \"${base_dn}\" -D \"uid=${user},${subfilter_dn}\" -w \"${passwd}\" \"(&(objectClass=inetOrgPerson)(memberOf=cn=admins,cn=groups,cn=accounts,${base_dn}))\" | grep 'dn: uid' | awk '{print substr(\$2,5)}' | sed 's/,${subfilter_dn}//g')"
  $bacula_init = @("BACULAINIT")
    sudo -H -u postgres bash -c '${bacula_root}/scripts/create_postgresql_database'
    sudo -H -u postgres bash -c '${bacula_root}/scripts/make_postgresql_tables'
    sudo -H -u postgres bash -c '${bacula_root}/scripts/grant_postgresql_privileges'
    |BACULAINIT
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
  $pip3_packages = [
    'pypsexec',
    'pywinrm',
    'pypsrp',
  ]
  $create_cert = @("CERT")
    #!/usr/bin/bash
    cat ${le_root}/privkey.pem <(echo) ${le_root}/cert.pem > ${bacula_crt}/${cert_name}
    |CERT
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
          'customer_id' => '${id}',
          'dbi' => 'DBI:Pg:database=bacula',
          'workset_dir' => '${bacula_root}/working/conf.d',
          'debug' => 0,
          'user' => 'bacula',
          'config_dir' => '${bacula_etc}/conf.d',
          'html_dir' => '${bacula_web_root}/html',
          'stat_job_table' => 'JobHisto',
          'display_log_time' => 'on',
          'lang' => 'en',
          'wiki_url' => '',
          'rows_per_page' => '20',
          'description' => undef,
          'bconsole' => '${bacula_root}/bin/bconsole -n -c ${bacula_etc}/bconsole.conf',
          'hide_bconfig_menu_item' => 0,
          'fv_write_path' => '${bacula_web_root}/spool',
          'template_dir' => '${bacula_web_root}/tpl',
          'enable_security_acl' => 0,
          'email_media' => '${email}',
          'default_age' => '7d',
          'ssl_dir' => '${bacula_ssl}',
          'default_limit' => '100'
        };
    |BWEBCONF
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
  $s3_cloud = @("CLOUD")
    Cloud {
      Name = "IT-LS-S3"
      AccessKey = "${aws_access_key}"
      BucketName = "${aws_bucket}"
      Driver = "S3"
      HostName = "${aws_hostname}"
      SecretKey = "${aws_secret_key}"
      Upload = AtEndOfJob
      TruncateCache = AfterUpload
      UriStyle = Path
    }
    |CLOUD
  $s3_storage = @("S3STORE")
    Storage {
      Name = "IT-LS-S3"
      Address = it-bacula
      Device = "IT-LS-S3"
      MaximumConcurrentJobs = 50
      MediaType = "it-ls-media"
      Password = "${bacula_pwd}"
      SdPort = 9103
    }
    |S3STORE
  $s3_conf = @("S3CONF")
    @|"/opt/bweb/bin/workset_list.pl \"${bacula_root}/etc/conf.d/Storage/it-backup-s3\" \"${bacula_root}/working/conf.d/Storage/it-backup-s3\""
    |S3CONF
  $bacula_sd_conf = @("STORAGE")
    Autochanger {
      Name = "DiskAutochanger"
      ChangerCommand = ""
      ChangerDevice = "/dev/null"
      Device = "DiskAutochanger_Dev0","DiskAutochanger_Dev1","DiskAutochanger_Dev2"
    }
    Device {
      Name = "DiskAutochanger_Dev0"
      AlwaysOpen = no
      ArchiveDevice = "${bacula_root}/archive"
      AutomaticMount = yes
      DeviceType = File
      DriveIndex = 0
      LabelMedia = yes
      MaximumConcurrentJobs = 5
      MediaType = "DiskVolume"
      RandomAccess = yes
      RemovableMedia = no
    }
    Device {
      Name = "DiskAutochanger_Dev1"
      AlwaysOpen = no
      ArchiveDevice = "${bacula_root}/archive"
      AutomaticMount = yes
      DeviceType = File
      DriveIndex = 1
      LabelMedia = yes
      MaximumConcurrentJobs = 5
      MediaType = "DiskVolume"
      RandomAccess = yes
      RemovableMedia = no
    }
    Device {
      Name = "DiskAutochanger_Dev2"
      AlwaysOpen = no
      ArchiveDevice = "${bacula_root}/archive"
      AutoSelect = no
      AutomaticMount = yes
      DeviceType = File
      DriveIndex = 2
      LabelMedia = yes
      MaximumConcurrentJobs = 5
      MediaType = "DiskVolume"
      RandomAccess = yes
      RemovableMedia = no
    }
    Device {
      Name = "DiskCatalogDevice"
      AlwaysOpen = no
      ArchiveDevice = "${bacula_root}/archive"
      AutomaticMount = yes
      DeviceType = File
      LabelMedia = yes
      MaximumConcurrentJobs = 1
      MediaType = "CatalogVolume"
      RandomAccess = yes
      RemovableMedia = no
    }
    Director {
      Name = "it-bacula-dir"
      Password = "${bacula_pwd}"
    }
    Messages {
      Name = "Default"
      Append  = "${bacula_root}/log/it-bacula-sd.log" = All,!Skipped
      Director  = "it-bacula-dir" = All
    }
    Storage {
      Name = "it-bacula-sd"
      MaximumConcurrentJobs = 20
      PidDirectory = "${bacula_root}/working"
      PluginDirectory = "${bacula_root}/plugins"
      WorkingDirectory = "${bacula_root}/working"
    }    
    Cloud {
      Name = "IT-LS-S3"
      AccessKey = "${aws_access_key}"
      BucketName = "it-backup"
      Driver = "S3"
      HostName = "${aws_hostname}"
      SecretKey = "${aws_secret_key}"
      Upload = AtEndOfJob
      TruncateCache = AfterUpload
      UriStyle = Path
    }
    Device {
      Name = "IT-LS-S3"
      AlwaysOpen = yes
      ArchiveDevice = "${bacula_root}/archive/s3"
      AutomaticMount = yes
      Cloud = "IT-LS-S3"
      DeviceType = Cloud
      LabelMedia = yes
      MaximumConcurrentJobs = 10
      MaximumFileSize = 53687091200
      MaximumPartSize = 1000000000
      MaximumVolumeSize = 536870912000
      MediaType = "it-ls-media"
      RandomAccess = yes
      RemovableMedia = no
    }
    |STORAGE
  ##########################
  #  Files definition
  ##########################
  #  Create root directories
  file { [$bacula_ssl,
    "${bacula_ssl}/certs",]:
      ensure  => directory,
      recurse => true,
      owner   => 'bacula',
      group   => 'bacula',
      mode    => '0644',
  }
  #  Create User's private sshkey file
  -> file { "${bacula_ssl}/ssh/${user}_key":
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0600',
    content => $ssh_priv_key,
    require => Exec["${scripts_dir}/cert_gen.sh"],
  }
  #  Create User's public sshkey file
  -> file { "${bacula_ssl}/ssh/${user}_key.pub":
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0640',
    content => $ssh_pub_key,
    require => Exec["${scripts_dir}/cert_gen.sh"],
  }
  #  Create scripts directory
  file { $scripts_dir:
    ensure => directory,
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
  #  Manage Bacula Web httpd.conf
  file { "${bacula_web_etc}/httpd.conf":
    ensure  => file,
    mode    => '0644',
    notify  => Service['bweb'],
    require => Package[$bacula_web],
    content => $ssl_config,
  }
  #  S3 directories creation
  file { ["${bacula_root}/archive",
    "${bacula_root}/archive/s3",]:
      ensure => directory,
      owner  => 'bacula',
      group  => 'bacula',
      mode   => '0644',
  }
  file { "${bacula_etc}/conf.d/Director/it-bacula-dir/Storage/IT-LS-S3.cfg":
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0640',
    content => $s3_storage,
    notify  => Service['bacula-sd'],
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
  #  Import Licenced GPG Bacula Key
  file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-BACULA':
    ensure => file,
    source => "https://www.baculasystems.com/dl/${id}/BaculaSystems-Public-Signature-08-2017.asc",
  }
  #  Creates IPA Bacula users population script
  file { $admin_script:
    ensure  => file,
    mode    => '0755',
    content => $process_admin,
  }
  #  Create root directories for sshkey
  file { ["${bacula_web_etc}/conf.d",
      "${bacula_web_etc}/conf.d/ssl",
    "${bacula_web_etc}/conf.d/ssl/ssh/",]:
      ensure => directory,
      owner  => 'bacula',
      group  => 'bacula',
      mode   => '0700',
  }
  #  Create Bacula Cert generator script
  file { "${scripts_dir}/cert_gen.sh":
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0755',
    content => $create_cert,
    require => File[$scripts_dir],
  }
  #  Create Cloud Tree Structure
  file { ["${bacula_root}/working",
    "${bacula_root}/working/conf.d",]:
      ensure => directory,
      owner  => 'bacula',
      group  => 'bacula',
      mode   => '0644',
  }
  -> file { ["${bacula_root}/working/conf.d/Storage",
      "${bacula_root}/working/conf.d/Storage/it-backup-s3",
      "${bacula_root}/working/conf.d/Storage/it-backup-s3/Cloud",
      "${bacula_root}/working/conf.d/Storage/it-backup-s3/Device",
      "${bacula_root}/working/conf.d/Storage/it-backup-s3/Director",
      "${bacula_root}/working/conf.d/Storage/it-backup-s3/Messages",
    "${bacula_root}/working/conf.d/Storage/it-backup-s3/Storage",]:
      ensure => directory,
      owner  => 'bacula',
      group  => 'bacula',
      mode   => '0755',
  }
  #  Create S3 management Cloud file
  -> file { "${bacula_root}/working/conf.d/Storage/it-backup-s3/Cloud/IT-LS-S3.cfg":
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0640',
    content => $s3_cloud,
  }
  -> file { "${bacula_root}/working/conf.d/Storage/it-backup-s3/Storage.conf":
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0640',
    content => $s3_conf,
  }
  file { "${bacula_etc}/bacula-sd.conf":
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0640',
    content => $bacula_sd_conf,
    notify  => Service['bacula-sd'],
  }
  ##########################
  #  Manual Execusions
  ##########################
  #  Run the first run to get the certificated
  exec { "${scripts_dir}/cert_gen.sh":
    cwd     => '/var/tmp/',
    path    => ['/sbin', '/usr/sbin', '/bin'],
    unless  => "test -f ${bacula_etc}/conf.d/ssl/certs/baculacert.pem",
    require => File["${scripts_dir}/cert_gen.sh"],
  }
  #  Initialize Postgres Bacula DB
  exec { $bacula_init:
    cwd     => $bacula_root,
    path    => ['/sbin', '/usr/sbin', '/bin'],
    unless  => "sudo -H -u postgres bash -c 'psql -l' | grep bacula",
    require => Package[$bacula_package],
  }
  #  Provision bweb tables to psql
  exec { "sudo bash ${bacula_web_root}/bin/install_bweb.sh":
    cwd     => '/var/tmp/',
    path    => ['/sbin', '/usr/sbin', '/bin'],
    require => Package[$bacula_web],
    unless  => 'sudo -H -u postgres bash -c \'psql -U postgres -d bacula -E -c "\dt"\' | grep bweb',
  }
  #  Populate BWeb with Admin IPA Users
  exec { "sudo -H -u postgres bash -c ${scripts_dir}/get_admins.sh":
    cwd     => '/var/tmp/',
    path    => ['/sbin', '/usr/sbin', '/bin'],
    unless  => "sudo -H -u postgres bash -c 'psql -U postgres -d bacula -E -c \"select * from bweb_user\"' | grep ${user}",
    require => File[$admin_script],
  }
  #  Ensure Bacula's Python3 required packages
  exec { 'python3 -m pip install --upgrade pip==21.3.1':
    cwd     => '/var/tmp/',
    path    => ['/sbin', '/usr/sbin', '/bin'],
    unless  => 'pip3 --version | grep 21.3.1',
    require => File[$admin_script],
  }
  # #  HTTPD File definition
  # file { '/etc/httpd/conf.d/bweb.conf':
  #   ensure  => file,
  #   mode    => '0644',
  #   content => $httpd_conf,
  #   notify  => Service['httpd'],
  # }
  ##########################
  #  Packages installation
  ##########################
  #  Bacula Enterprise Repository
  yumrepo { 'bacula':
    ensure   => 'present',
    baseurl  => "https://www.baculasystems.com/dl/${id}/rpms/bin/${version}/rhel7-64/",
    descr    => 'Bacula Enterprise Repository',
    enabled  => true,
    gpgcheck => '1',
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-BACULA',
    require  => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-BACULA'],
  }
  #  BWeb Repository
  yumrepo { 'bacula-bweb':
    ensure   => 'present',
    baseurl  => "https://www.baculasystems.com/dl/${id}/rpms/bweb/${version}/rhel7-64/",
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
    baseurl  => "https://www.baculasystems.com/dl/${id}/rpms/vsphere/${version}/rhel7-64/",
    descr    => 'Bacula vSphere-Plugin Repository',
    gpgkey   => 'https://www.baculasystems.com/dl/keys/BaculaSystems-Public-Signature-08-2017.asc',
    enabled  => true,
    gpgcheck => '0',
  }
  #  Bacula vSphere Plugin Repository
  yumrepo { 'bacula-cloud':
    ensure   => 'present',
    baseurl  => "https://www.baculasystems.com/dl/${id}/rpms/cloud-s3/${version}/rhel7-64/",
    descr    => 'Bacula S3-Cloud-Plugin Repository',
    gpgkey   => 'https://www.baculasystems.com/dl/keys/BaculaSystems-Public-Signature-08-2017.asc',
    enabled  => true,
    gpgcheck => '1',
  }
  #  Install pip3 packages
  package { $pip3_packages:
    ensure   => 'present',
    provider => 'pip3',
    require  => Exec['python3 -m pip install --upgrade pip==21.3.1'],
  }
  #  Ensure Packages installation
  package { $packages:
    ensure => 'present',
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
  #  Install Bacula Cloud S3 Plugin
  package { $bacula_cloud_plugin:
    ensure  => 'present',
    require => Yumrepo['bacula-cloud'],
  }
  ##########################
  #  Services definition
  ##########################
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
  #  Manage HTTPD Service
  service { 'httpd':
    ensure  => 'running',
    enable  => true,
    require => Package[$packages],
  }
  ##########################
  #  Other tasks
  ##########################
  #  Generate and sign certificate
  letsencrypt::certonly { $fqdn:
    plugin      => 'dns-route53',
    manage_cron => true,
  }
  #  BSys_report Generation
  archive { '/var/tmp/bsys_report.tar.gz':
    source       => 'http://www.baculasystems.com/ml/bsys_report/bsys_report.tar.gz',
    extract      => true,
    extract_path => $opt,
    user         => 'root',
    group        => 'root',
  }
  #  Change PrivateKey mode every month
  cron::job { 'baculacert':
    ensure      => present,
    minute      => '0',
    hour        => '0',
    date        => '*/1',
    month       => '*',
    weekday     => '*',
    command     => "sh ${scripts_dir}/cert_gen.sh",
    description => 'Combined Cert for Bacula Web',
    require     => Package[$bacula_web],
    notify      => Service['bweb'],
  }
}

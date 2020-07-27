# @summary
#   Definition of icinga and icingaweb master module

class profile::it::icinga_master (
  $ldap_server,
  $ldap_root,
  $ldap_user,
  $ldap_pwd,
  $ldap_resource,
  $ldap_user_filter,
  $ldap_group_filter,
  $ldap_group_base,
  $ssl_name,
  $ssl_country,
  $ssl_org,
  $ssl_fqdn,
  $mysql_root,
  $mysql_icingaweb_db,
  $mysql_icingaweb_user,
  $mysql_icingaweb_pwd,
  $mysql_director_db,
  $mysql_director_user,
  $mysql_director_pwd,
  $api_name,
  $api_user,
  $api_pwd,
  $hash,
  $host_tpl,
  $http_tpl,
  $dns_tpl,
  $dhcp_tpl,
  $tfm_tpl,
)
{
include profile::core::common
include profile::core::remi
include ::openssl
include ::nginx

$ssl_cert       = '/etc/ssl/certs/icinga.crt'
$ssl_key        = '/etc/ssl/certs/icinga.key'
$master_fqdn  = $facts[fqdn]
$master_ip  = $facts[ipaddress]
$php_packages = [
  'php73-php-fpm',
  'php73-php-ldap',
  'php73-php-intl',
  'php73-php-dom',
  'php73-php-gd',
  'php73-php-imagick',
  'php73-php-mysqlnd',
  'php73-php-pgsql',
  'php73-php-pdo',
  'php73-php-process',
  'php73-php-cli',
  'php73-php-soap',
  'rh-php73-php-posix',
]
$override_options = {
  'mysqld' => {
    'bind_address' => '0.0.0.0',
  }
}
$http_svc_tpl_name  = 'HttpServiceTemplate'
$ping_svc_tpl_name  = 'PingServiceTemplate'
$dns_svc_tpl_name   = 'DnsServiceTemplate'
$dhcp_svc_tpl_name  = 'DhcpServiceTemplate'
$tfm_svc_name       = 'TfmService'
$tfm_svc_http_name  = 'TfmHttpService'
$tfm_svc_dhcp_name  = 'TfmDhcpService'
$tfm_svc_ping_name  = 'TfmPingService'
$dns_svc_name       = 'DnsService'
$dns_svc_ping_name  = 'DnsPingService'
$dhcp_svc_name      = 'DhcpService'
$dhcp_svc_ping_name = 'DhcpPingService'
$http_svc_name      = 'HttpService'
$http_svc_ping_name = 'HttpPingService'

##Hosts Templates JSON
$general_template = "{
\"accept_config\": true,
\"check_command\": \"hostalive\",
\"has_agent\": true,
\"master_should_connect\": true,
\"max_check_attempts\": \"5\",
\"object_name\": \"${host_tpl}\",
\"object_type\": \"template\"
}"
$http_template = "{
\"accept_config\": true,
\"check_command\": \"hostalive\",
\"has_agent\": true,
\"master_should_connect\": true,
\"max_check_attempts\": \"5\",
\"object_name\": \"${http_tpl}\",
\"object_type\": \"template\"
}"
$dns_template = "{
\"accept_config\": true,
\"check_command\": \"hostalive\",
\"has_agent\": true,
\"master_should_connect\": true,
\"max_check_attempts\": \"5\",
\"object_name\": \"${dns_tpl}\",
\"object_type\": \"template\"
}"
$dhcp_template = "{
\"accept_config\": true,
\"check_command\": \"hostalive\",
\"has_agent\": true,
\"master_should_connect\": true,
\"max_check_attempts\": \"5\",
\"object_name\": \"${dhcp_tpl}\",
\"object_type\": \"template\"
}"
$tfm_template = "{
\"accept_config\": true,
\"check_command\": \"hostalive\",
\"has_agent\": true,
\"master_should_connect\": true,
\"max_check_attempts\": \"5\",
\"object_name\": \"${tfm_tpl}\",
\"object_type\": \"template\"
}"

##Service Template JSON
$http_svc_tpl = "{
\"check_command\": \"http\",
\"object_name\": \"${http_svc_tpl_name}\",
\"object_type\": \"template\",
\"use_agent\": true,
\"zone\": \"master\"
}"
$ping_svc_tpl = "{
\"check_command\": \"hostalive\",
\"object_name\": \"${ping_svc_tpl_name}\",
\"object_type\": \"template\",
\"use_agent\": true,
\"zone\": \"master\"
}"
$dns_svc_tpl = "{
\"check_command\": \"dns\",
\"object_name\": \"${dns_svc_tpl_name}\",
\"object_type\": \"template\",
\"use_agent\": true,
\"zone\": \"master\"
}"
$dhcp_svc_tpl = "{
\"check_command\": \"dhcp\",
\"object_name\": \"${dhcp_svc_tpl_name}\",
\"object_type\": \"template\",
\"use_agent\": true,
\"zone\": \"master\"
}"

##Services Definition
#HTTP and Ping monitoring
$http_svc1 = "{
\"host\": \"${http_tpl}\",
\"imports\": [
  \"${$http_svc_tpl_name}\"
],
\"object_name\": \"${http_svc_name}\",
\"object_type\": \"object\"
}"
$http_svc2 = "{
\"host\": \"${http_tpl}\",
\"imports\": [
    \"${$ping_svc_tpl_name}\"
],
\"object_name\": \"${http_svc_ping_name}\",
\"object_type\": \"object\"
}"
#DHCP and Ping monitoring
$dhcp_svc1 = "{
\"host\": \"${dhcp_tpl}\",
\"imports\": [
  \"${$dhcp_svc_tpl_name}\"
],
\"object_name\": \"${dhcp_svc_name}\",
\"object_type\": \"object\"
}"
$dhcp_svc2 = "{
\"host\": \"${dhcp_tpl}\",
\"imports\": [
  \"${$ping_svc_tpl_name}\"
],
\"object_name\": \"${dhcp_svc_ping_name}\",
\"object_type\": \"object\"
}"
#DNS and Ping monitoring
$dns_svc1 = "{
\"host\": \"${dns_tpl}\",
\"imports\": [
  \"${$dns_svc_tpl_name}\"
],
\"object_name\": \"${dns_svc_name}\",
\"object_type\": \"object\"
}"
$dns_svc2 = "{
\"host\": \"${dns_tpl}\",
\"imports\": [
  \"${$ping_svc_tpl_name}\"
],
\"object_name\": \"${dns_svc_ping_name}\",
\"object_type\": \"object\"
}"
#HTTP, DHCP and Ping monitoring
$tfm_svc1 = "{
\"host\": \"${tfm_tpl}\",
\"imports\": [
  \"${$http_svc_tpl_name}\"
],
\"object_name\": \"${$tfm_svc_http_name}\",
\"object_type\": \"object\"
}"
$tfm_svc2 = "{
\"host\": \"${tfm_tpl}\",
\"imports\": [
  \"${$dhcp_svc_tpl_name}\"
],
\"object_name\": \"${$tfm_svc_dhcp_name}\",
\"object_type\": \"object\"
}"
$tfm_svc3 = "{
\"host\": \"${tfm_tpl}\",
\"imports\": [
  \"${$ping_svc_tpl_name}\"
],
\"object_name\": \"${$tfm_svc_ping_name}\",
\"object_type\": \"object\"
}"

##Master Node JSON
  $add_master_host = "{
\"address\": \"${master_ip}\",
\"display_name\": \"${master_fqdn}\",
\"imports\": [
  \"${http_tpl}\"
],
\"object_name\":\"${master_fqdn}\",
\"object_type\": \"object\",
\"vars\": {
    \"safed_profile\": \"3\"
}
}"


##General Variables Definition
$url = "https://${master_fqdn}/director"
$url_host = "https://${master_fqdn}/director/host"
$url_svc = "https://${master_fqdn}/director/service"
$credentials = "Authorization:Basic ${hash}"
$format = 'Accept: application/json'
$curl = 'curl -s -k -H'
$icinga_path = '/opt/icinga'
##Create a directory to allocate json files
file { $icinga_path:
  ensure => 'directory',
}

#Host Templates Creation
$host_tpl_path = "${$icinga_path}/${host_tpl}.json"
$host_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${host_tpl}' | grep Failed"
$host_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${host_tpl_path}"

$http_tpl_path = "${icinga_path}/${http_tpl}.json"
$http_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${http_tpl}' | grep Failed"
$http_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${http_tpl_path}"

$dns_tpl_path = "${icinga_path}/${dns_tpl}.json"
$dns_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${dns_tpl}' | grep Failed"
$dns_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${dns_tpl_path}"

$dhcp_tpl_path = "${icinga_path}/${dhcp_tpl}.json"
$dhcp_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${dhcp_tpl}' | grep Failed"
$dhcp_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${dhcp_tpl_path}"

$tfm_tpl_path = "${icinga_path}/${tfm_tpl}.json"
$tfm_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${tfm_tpl}' | grep Failed"
$tfm_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${tfm_tpl_path}"

#Services Template Creation
$http_svc_tpl_path = "${icinga_path}/${http_svc_tpl_name}.json"
$http_svc_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_tpl_name}' | grep Failed"
$http_svc_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$http_svc_tpl_path}"

$ping_svc_tpl_path = "${icinga_path}/${ping_svc_tpl_name}.json"
$ping_svc_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ping_svc_tpl_name}' | grep Failed"
$ping_svc_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$ping_svc_tpl_path}"

$dns_svc_tpl_path  = "${icinga_path}/${dns_svc_tpl_name}.json"
$dns_svc_tpl_cond  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_tpl_name}' | grep Failed"
$dns_svc_tpl_cmd   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$dns_svc_tpl_path}"

$dhcp_svc_tpl_path = "${icinga_path}/${dhcp_svc_tpl_name}.json"
$dhcp_svc_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dhcp_svc_tpl_name}' | grep Failed"
$dhcp_svc_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$dhcp_svc_tpl_path}"

#Services Creation
$http_svc_path1 = "${icinga_path}/${http_svc_name}.json"
$http_svc_cond1 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_name}&host=${http_tpl}' | grep Failed"
$http_svc_cmd1  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path1}"
$http_svc_path2 = "${icinga_path}/${http_svc_ping_name}.json"
$http_svc_cond2 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_ping_name}&host=${http_tpl}' | grep Failed"
$http_svc_cmd2  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path2}"

$dns_svc_path1  = "${icinga_path}/${dns_svc_name}.json"
$dns_svc_cond1  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_name}&host=${dns_tpl}' | grep Failed"
$dns_svc_cmd1   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path1}"
$dns_svc_path2  = "${icinga_path}/${dns_svc_ping_name}.json"
$dns_svc_cond2  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_ping_name}&host=${dns_tpl}' | grep Failed"
$dns_svc_cmd2   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path2}"

$dhcp_svc_path1  = "${icinga_path}/${dhcp_svc_name}.json"
$dhcp_svc_cond1  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dhcp_svc_name}&host=${dhcp_tpl}' | grep Failed"
$dhcp_svc_cmd1   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dhcp_svc_path1}"
$dhcp_svc_path2  = "${icinga_path}/${dhcp_svc_ping_name}.json"
$dhcp_svc_cond2  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dhcp_svc_ping_name}&host=${dhcp_tpl}' | grep Failed"
$dhcp_svc_cmd2   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dhcp_svc_path2}"

$tfm_svc_path1  = "${icinga_path}/${tfm_svc_http_name}.json"
$tfm_svc_cond1  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${tfm_svc_name}&host=${tfm_tpl}' | grep Failed"
$tfm_svc_cmd1   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${tfm_svc_path1}"
$tfm_svc_path2  = "${icinga_path}/${tfm_svc_dhcp_name}.json"
$tfm_svc_cond2  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${tfm_svc_dhcp_name}&host=${tfm_tpl}' | grep Failed"
$tfm_svc_cmd2   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${tfm_svc_path2}"
$tfm_svc_path3  = "${icinga_path}/${tfm_svc_ping_name}.json"
$tfm_svc_cond3  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${tfm_svc_ping_name}&host=${tfm_tpl}' | grep Failed"
$tfm_svc_cmd3   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${tfm_svc_path3}"

#Master Host Creation
$addhost_path = "${icinga_path}/${master_fqdn}.json"
$addhost_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${master_fqdn}' | grep Failed"
$addhost_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${addhost_path}"

#Force Deploy pending requests
$deploy_cmd = "${curl} '${credentials}' -H '${format}' -X POST '${url}/config/deploy'"


##Host Templates
#Create host template file
  file { $host_tpl_path:
    ensure  => 'present',
    content => $general_template,
    before  => Exec[$host_tpl_cmd],
  }
#Add general host template
  exec { $host_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $host_tpl_cond,
  }
#Create http template file
  file { $http_tpl_path:
    ensure  => 'present',
    content => $http_template,
    before  => Exec[$http_tpl_cmd],
  }
#Add http template
  exec { $http_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_tpl_cond,
  }
#Create dns template file
  file { $dns_tpl_path:
    ensure  => 'present',
    content => $dns_template,
    before  => Exec[$dns_tpl_cmd],
  }
#Add dns template
  exec { $dns_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_tpl_cond,
  }
#Create dhcp file
  file { $dhcp_tpl_path:
    ensure  => 'present',
    content => $dhcp_template,
    before  => Exec[$dhcp_tpl_cmd],
  }
#Add dhcp template
  exec { $dhcp_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dhcp_tpl_cond,
  }
#Create foreman file
  file { $tfm_tpl_path:
    ensure  => 'present',
    content => $tfm_template,
    before  => Exec[$tfm_tpl_cmd],
  }
#Add foreman template
  exec { $tfm_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $tfm_tpl_cond,
  }

##Service Templates
#Create http template file
  file { $http_svc_tpl_path:
    ensure  => 'present',
    content => $http_svc_tpl,
    before  => Exec[$http_svc_tpl_cmd],
  }
#Add http template
  exec { $http_svc_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_svc_tpl_cond,
  }
#Create ping template file
  file { $ping_svc_tpl_path:
    ensure  => 'present',
    content => $ping_svc_tpl,
    before  => Exec[$ping_svc_tpl_cmd],
  }
#Add http template
  exec { $ping_svc_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ping_svc_tpl_cond,
  }
#Create dhcp template file
  file { $dhcp_svc_tpl_path:
    ensure  => 'present',
    content => $dhcp_svc_tpl,
    before  => Exec[$dhcp_svc_tpl_cmd],
  }
#Add http template
  exec { $dhcp_svc_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dhcp_svc_tpl_cond,
  }
#Create dns template file 
  file { $dns_svc_tpl_path:
    ensure  => 'present',
    content => $dns_svc_tpl,
    before  => Exec[$dns_svc_tpl_cmd],
  }
#Add http template
  exec { $dns_svc_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_svc_tpl_cond,
  }

##Services Definition
#Creates http resource file for HttpTemplate and HttpServiceTemplate
  file { $http_svc_path1:
    ensure  => 'present',
    content => $http_svc1,
    before  => Exec[$http_svc_cmd1],
  }
#Adds http resource file for HttpTemplate and HttpServiceTemplate
  exec { $http_svc_cmd1:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_svc_cond1,
  }
#Creates ping resource file for HttpTemplate and HttpServiceTemplate
  file { $http_svc_path2:
    ensure  => 'present',
    content => $http_svc2,
    before  => Exec[$http_svc_cmd2],
  }
#Adds ping resource file for HttpTemplate and HttpServiceTemplate
  exec { $http_svc_cmd2:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_svc_cond2,
  }
#Creates dhcp resource file for DhcpTemplate and DhcpServiceTemplate
  file { $dhcp_svc_path1:
    ensure  => 'present',
    content => $dhcp_svc1,
    before  => Exec[$dhcp_svc_cmd1],
  }
#Adds dhcp resource file for DhcpTemplate and DhcpServiceTemplate
  exec { $dhcp_svc_cmd1:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dhcp_svc_cond1,
  }
#Creates ping resource file for DhcpTemplate and DhcpServiceTemplate
  file { $dhcp_svc_path2:
    ensure  => 'present',
    content => $dhcp_svc2,
    before  => Exec[$dhcp_svc_cmd2],
  }
#Adds ping resource file for DhcpTemplate and DhcpServiceTemplate
  exec { $dhcp_svc_cmd2:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dhcp_svc_cond2,
  }
#Creates dns resource file for DnsTemplate and DnsServiceTemplate
  file { $dns_svc_path1:
    ensure  => 'present',
    content => $dns_svc1,
    before  => Exec[$dns_svc_cmd1],
  }
#Adds dns resource file for DnsTemplate and DnsServiceTemplate
  exec { $dns_svc_cmd1:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_svc_cond1,
  }
#Creates ping resource file for DnsTemplate and DnsServiceTemplate
  file { $dns_svc_path2:
    ensure  => 'present',
    content => $dns_svc2,
    before  => Exec[$dns_svc_cmd2],
  }
#Adds ping resource file for DnsTemplate and DnsServiceTemplate
  exec { $dns_svc_cmd2:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_svc_cond2,
  }
#Adds http resource file for TfmTemplate and TfmServiceTemplate
  file { $tfm_svc_path1:
    ensure  => 'present',
    content => $tfm_svc1,
    before  => Exec[$tfm_svc_cmd1],
  }
#Creates http resource file for TfmTemplate and TfmServiceTemplate
  exec { $tfm_svc_cmd1:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $tfm_svc_cond1,
  }
#Adds dhcp resource file for TfmTemplate and TfmServiceTemplate
  file { $tfm_svc_path2:
    ensure  => 'present',
    content => $tfm_svc2,
    before  => Exec[$tfm_svc_cmd2],
  }
#Creates dhcp resource file for TfmTemplate and TfmServiceTemplate
  exec { $tfm_svc_cmd2:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $tfm_svc_cond2,
  }
#Adds ping resource file for TfmTemplate and TfmServiceTemplate
  file { $tfm_svc_path3:
    ensure  => 'present',
    content => $tfm_svc3,
    before  => Exec[$tfm_svc_cmd3],
  }
#Creates ping resource file for TfmTemplate and TfmServiceTemplate
  exec { $tfm_svc_cmd3:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $tfm_svc_cond3,
  }


##Add Master Host
#Create master host file
  file { $addhost_path:
    ensure  => 'present',
    content => $add_master_host,
    before  => Exec[$addhost_cmd],
  }
#Add master host
  exec { $addhost_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $addhost_cond,
  }

##Ensure php73 packages and services
  package { $php_packages:
    ensure => 'present',
  }
  service { 'php73-php-fpm':
    ensure  => 'running',
    require => Package[$php_packages],
  }

## SSL Certificate Creation
  openssl::certificate::x509 { $ssl_name:
    country      => $ssl_country,
    organization => $ssl_org,
    commonname   => $ssl_fqdn,
  }

##MySQL definition
  class { '::mysql::server':
    root_password           => $mysql_root,
    remove_default_accounts => true,
    restart                 => true,
    override_options        => $override_options,
  }
  mysql::db { $mysql_icingaweb_db:
    user     => $mysql_icingaweb_user,
    password => $mysql_icingaweb_pwd,
    host     => $master_ip,
    grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE VIEW', 'CREATE', 'INDEX', 'EXECUTE', 'ALTER', 'REFERENCES'],
  }
  mysql::db { $mysql_director_db:
    user     => $mysql_director_user,
    password => $mysql_director_pwd,
    host     => $master_ip,
    charset  => 'utf8',
    grant    => ['SELECT', 'INSERT', 'UPDATE', 'DELETE', 'DROP', 'CREATE VIEW', 'CREATE', 'INDEX', 'EXECUTE', 'ALTER', 'REFERENCES'],
  }

##Icinga2 Config
  class { '::icinga2':
    manage_repo => true,
    confd       => false,
    constants   => {
      'ZoneName'   => 'master',
    },
    features    => ['checker','mainlog','statusdata','compatlog','command'],
  }
  class { '::icinga2::feature::idomysql':
    user          => $mysql_icingaweb_user,
    password      => $mysql_icingaweb_pwd,
    database      => $mysql_icingaweb_db,
    host          => $master_ip,
    import_schema => true,
    require       => Mysql::Db[$mysql_icingaweb_db],
  }
  class { '::icinga2::feature::api':
    pki             => 'puppet',
    accept_config   => true,
    accept_commands => true,
    ensure          => 'present',
    endpoints       => {
      $master_fqdn    => {
        'host'  =>  $master_ip
      },
    },
    zones           => {
      'master'    => {
        'endpoints' => [$master_fqdn],
      },
    },
  }
  class { '::icinga2::feature::notification':
    ensure    => present,
    enable_ha => true,
  }
  icinga2::object::apiuser { $api_user:
    ensure      => present,
    password    => $api_pwd,
    permissions => [ '*' ],
    target      => '/etc/icinga2/features-enabled/api-users.conf',
  }
  icinga2::object::zone { 'director-global':
    global => true,
  }

##IcingaWeb Config
  class {'::icingaweb2':
    manage_repo   => false,
    logging_level => 'DEBUG',
  }
  class {'icingaweb2::module::monitoring':
    ensure            => present,
    ido_host          => $master_ip,
    ido_type          => 'mysql',
    ido_db_name       => $mysql_icingaweb_db,
    ido_db_username   => $mysql_icingaweb_user,
    ido_db_password   => $mysql_icingaweb_pwd,
    commandtransports => {
      $api_name => {
        transport => 'api',
        host      => $master_ip,
        port      => 5565,
        username  => $api_user,
        password  => $api_pwd,
      }
    }
  }
##IcingaWeb LDAP Config
  icingaweb2::config::resource{ $ldap_resource:
    type         => 'ldap',
    host         => $ldap_server,
    port         => 389,
    ldap_root_dn => $ldap_root,
    ldap_bind_dn => $ldap_user,
    ldap_bind_pw => $ldap_pwd,
  }
  icingaweb2::config::authmethod { 'ldap-auth':
    backend                  => 'ldap',
    resource                 => $ldap_resource,
    ldap_user_class          => 'inetOrgPerson',
    ldap_filter              => $ldap_user_filter,
    ldap_user_name_attribute => 'uid',
    order                    => '05',
  }
  icingaweb2::config::groupbackend { 'ldap-groups':
    backend                   => 'ldap',
    resource                  => $ldap_resource,
    ldap_group_class          => 'groupOfNames',
    ldap_group_name_attribute => 'cn',
    ldap_group_filter         => $ldap_group_filter,
    ldap_base_dn              => $ldap_group_base,
  }
  icingaweb2::config::role { 'Admin User':
    groups      => 'icinga-admins',
    permissions => '*',
  }
##IcingaWeb Director
  class {'icingaweb2::module::director':
    git_revision  => 'v1.7.2',
    db_host       => $master_ip,
    db_name       => $mysql_director_db,
    db_username   => $mysql_director_user,
    db_password   => $mysql_director_pwd,
    import_schema => true,
    kickstart     => true,
    endpoint      => $master_fqdn,
    api_host      => $master_ip,
    api_port      => 5665,
    api_username  => $api_user,
    api_password  => $api_pwd,
    require       => Mysql::Db[$mysql_director_db],
  }
  file {'/etc/icingaweb2/':
    notify => Service['php73-php-fpm'],
  }
##IcingaWeb Daemon
# User Creation
  $command1 = 'useradd -r -g icingaweb2 -d /var/lib/icingadirector -s /bin/false icingadirector'
  $command2 = 'install -d -o icingadirector -g icingaweb2 -m 0750 /var/lib/icingadirector'
  $command3 = 'cp /usr/share/icingaweb2/modules/director/contrib/systemd/icinga-director.service /etc/systemd/system/; systemctl daemon-reload'
  $command4 = 'systemctl enable --now icinga-director.service'
  $unless1  = 'grep icingadirector /etc/passwd'
  $onlyif2  = 'test ! -d /var/lib/icingadirector'
  $onlyif3  = 'test ! -f /etc/systemd/system/icinga-director.service'
  exec { $command1:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    unless   => $unless1,
  }
# User Directory
  ->exec { $command2:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $onlyif2,
  }
# Service Creation
  ->exec { $command3:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $onlyif3,
  }
# Run and Enable Service
  service { 'icinga-director':
    ensure => running,
  }

##IcingaWeb Reactbundle
  class {'icingaweb2::module::reactbundle':
    ensure         => present,
    git_repository => 'https://github.com/Icinga/icingaweb2-module-reactbundle',
    git_revision   => 'v0.7.0',
  }
##IcingaWeb IPL
  class {'icingaweb2::module::ipl':
    ensure         => present,
    git_repository => 'https://github.com/Icinga/icingaweb2-module-ipl',
    git_revision   => 'v0.3.0'
  }
##IcingaWeb Incubator
  class {'icingaweb2::module::incubator':
    ensure         => present,
    git_repository => 'https://github.com/Icinga/icingaweb2-module-incubator',
    git_revision   => 'v0.5.0'
  }


##Icinga Director DB migration
  exec { 'Icinga Director DB migration':
    path    => '/usr/local/bin:/usr/bin:/bin',
    command => 'icingacli director migration run',
    onlyif  => 'icingacli director migration pending',
  }
  exec { 'Icinga Director Kickstart':
    path    => '/usr/local/bin:/usr/bin:/bin',
    command => 'icingacli director kickstart run',
    onlyif  => 'icingacli director kickstart required',
    require => Exec['Icinga Director DB migration'],
  }

##Nginx Resource Definition
  nginx::resource::server { 'icingaweb2':
    server_name          => [$ssl_fqdn],
    ssl                  => true,
    ssl_cert             => $ssl_cert,
    ssl_key              => $ssl_key,
    ssl_redirect         => true,
    index_files          => ['index.php'],
    use_default_location => false,
    www_root             => '/usr/share/icingaweb2/public',
  }
  nginx::resource::location { 'root':
    location    => '/',
    server      => 'icingaweb2',
    try_files   => ['$1', '$uri', '$uri/', '/index.php$is_args$args'],
    index_files => [],
    ssl         => true,
    ssl_only    => true,
  }
  nginx::resource::location { 'icingaweb':
    location       => '~ ^/icingaweb2(.+)?',
    location_alias => '/usr/share/icingaweb2/public',
    try_files      => ['$1', '$uri', '$uri/', '/icingaweb2/index.php$is_args$args'],
    index_files    => ['index.php'],
    server         => 'icingaweb2',
    ssl            => true,
    ssl_only       => true,
  }
  nginx::resource::location { 'icingaweb2_index':
    location      => '~ ^/index\.php(.*)$',
    server        => 'icingaweb2',
    ssl           => true,
    ssl_only      => true,
    index_files   => [],
    try_files     => ['$uri =404'],
    fastcgi       => '127.0.0.1:9000',
    fastcgi_index => 'index.php',
    fastcgi_param => {
      'ICINGAWEB_CONFIGDIR' => '/etc/icingaweb2',
      'REMOTE_USER'         => '$remote_user',
      'SCRIPT_FILENAME'     => '/usr/share/icingaweb2/public/index.php',
    },
  }

  ##Force Deploy every puppet run
  exec { $deploy_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
  }
}

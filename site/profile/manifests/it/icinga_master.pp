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
  $master_tpl,
  $ipa_tpl,
)
{
include profile::core::common
include profile::core::remi
include ::openssl
include ::nginx

#<-------------Variables Definition---------------->

#Icinga tls keys
$ssl_cert       = '/etc/ssl/certs/icinga.crt'
$ssl_key        = '/etc/ssl/certs/icinga.key'

#Implicit usage of facts
$master_fqdn  = $facts[fqdn]
$master_ip  = $facts[ipaddress]

#Force installation and usage of php73
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
#Service Templates Names
$http_svc_tpl_name    = 'HttpServiceTemplate'
$ping_svc_tpl_name    = 'PingServiceTemplate'
$dns_svc_tpl_name     = 'DnsServiceTemplate'
$master_svc_tpl_name  = 'MasterServiceTemplate'
$ipa_svc_tpl_name     = 'IpaServiceTemplate'
$disk_svc_tpl_name    = 'DiskServiceTemplace'

#Service Names
$host_svc_ping_name   = 'HostPingService'
$host_svc_disk_name   = 'HostDiskService'
$dns_svc_name         = 'DnsService'
$dns_svc_ping_name    = 'DnsPingService'
$dns_svc_disk_name    = 'DnsDiskService'
$master_svc_dhcp_name = 'MasterDhcpService'
$master_svc_ping_name = 'MasterPingService'
$master_svc_disk_name = 'MasterDiskService'
$http_svc_name        = 'HttpService'
$http_svc_ping_name   = 'HttpPingService'
$http_svc_disk_name   = 'HttpDiskService'
$ipa_svc_name         = 'IpaService'
$ipa_svc_ping_name    = 'IpaPingService'
$ipa_svc_disk_name    = 'IpaDiskService'

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
$master_template = "{
\"accept_config\": true,
\"check_command\": \"hostalive\",
\"has_agent\": true,
\"master_should_connect\": true,
\"max_check_attempts\": \"5\",
\"object_name\": \"${master_tpl}\",
\"object_type\": \"template\"
}"
$ipa_template = "{
\"accept_config\": true,
\"check_command\": \"hostalive\",
\"has_agent\": true,
\"master_should_connect\": true,
\"max_check_attempts\": \"5\",
\"object_name\": \"${ipa_tpl}\",
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
$master_svc_tpl = "{
\"check_command\": \"dhcp\",
\"object_name\": \"${master_svc_tpl_name}\",
\"object_type\": \"template\",
\"use_agent\": true,
\"zone\": \"master\"
}"
$ipa_svc_tpl = "{
\"check_command\": \"ldap\",
\"object_name\": \"${ipa_svc_tpl_name}\",
\"object_type\": \"template\",
\"use_agent\": true,
\"vars\": {
    \"ldap_address\": \"localhost\",
    \"ldap_base\": \"dc=lsst,dc=cloud\"
},
\"zone\": \"master\"
}"
$disk_svc_tpl = "{
\"check_command\": \"disk\",
\"object_name\": \"${disk_svc_tpl_name}\",
\"object_type\": \"template\",
\"use_agent\": true,
\"vars\": {
    \"disk_cfree\": \"10%\",
    \"disk_wfree\": \"20%\"
},
\"zone\": \"master\"
}"

##Services Definition
#Ping, disk and RAM monitoring
$host_svc1 = "{
\"host\": \"${host_tpl}\",
\"imports\": [
    \"${$ping_svc_tpl_name}\"
],
\"object_name\": \"${host_svc_ping_name}\",
\"object_type\": \"object\"
}"
$host_svc2 = "{
\"host\": \"${host_tpl}\",
\"imports\": [
    \"${$disk_svc_tpl_name}\"
],
\"object_name\": \"${host_svc_disk_name}\",
\"object_type\": \"object\"
}"
#HTTP, Ping, disk and RAM monitoring
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
$http_svc3 = "{
\"host\": \"${http_tpl}\",
\"imports\": [
    \"${$disk_svc_tpl_name}\"
],
\"object_name\": \"${http_svc_disk_name}\",
\"object_type\": \"object\"
}"
#DHCP, Ping, disk and RAM monitoring
$master_svc1 = "{
\"host\": \"${master_tpl}\",
\"imports\": [
  \"${$master_svc_tpl_name}\"
],
\"object_name\": \"${master_svc_dhcp_name}\",
\"object_type\": \"object\",
\"vars\": {
  \"dhcp_serverip\": \"139.229.135.5\"
}"
$master_svc2 = "{
\"host\": \"${master_tpl}\",
\"imports\": [
  \"${$ping_svc_tpl_name}\"
],
\"object_name\": \"${master_svc_ping_name}\",
\"object_type\": \"object\"
}"
$master_svc3 = "{
\"host\": \"${master_tpl}\",
\"imports\": [
    \"${$disk_svc_tpl_name}\"
],
\"object_name\": \"${master_svc_disk_name}\",
\"object_type\": \"object\"
}"
#DNS, Ping, disk and RAM monitoring
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
$dns_svc3 = "{
\"host\": \"${dns_tpl}\",
\"imports\": [
    \"${$disk_svc_tpl_name}\"
],
\"object_name\": \"${dns_svc_disk_name}\",
\"object_type\": \"object\"
}"
#IPA, Ping, disk and RAM monitoring
$ipa_svc1 = "{
\"host\": \"${ipa_tpl}\",
\"imports\": [
  \"${$ipa_svc_tpl_name}\"
],
\"object_name\": \"${ipa_svc_name}\",
\"object_type\": \"object\"
}"
$ipa_svc2 = "{
\"host\": \"${ipa_tpl}\",
\"imports\": [
  \"${$ping_svc_tpl_name}\"
],
\"object_name\": \"${ipa_svc_ping_name}\",
\"object_type\": \"object\"
}"
$ipa_svc3 = "{
\"host\": \"${ipa_tpl}\",
\"imports\": [
    \"${$disk_svc_tpl_name}\"
],
\"object_name\": \"${ipa_svc_disk_name}\",
\"object_type\": \"object\"
}"

##Master Node JSON
  $add_master_host = "{
\"address\": \"${master_ip}\",
\"display_name\": \"${master_fqdn}\",
\"imports\": [
  \"${master_tpl}\"
],
\"object_name\":\"${master_fqdn}\",
\"object_type\": \"object\",
\"vars\": {
    \"safed_profile\": \"3\"
}
}"


##General Variables Definition
$url         = "https://${master_fqdn}/director"
$url_host    = "https://${master_fqdn}/director/host"
$url_svc     = "https://${master_fqdn}/director/service"
$credentials = "Authorization:Basic ${hash}"
$format      = 'Accept: application/json'
$curl        = 'curl -s -k -H'
$icinga_path = '/opt/icinga'
$lt          = '| grep Failed'

#Create a directory to allocate json files
file { $icinga_path:
  ensure => 'directory',
}

#Host Templates Creation
$host_tpl_path = "${$icinga_path}/${host_tpl}.json"
$host_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${host_tpl}' ${lt}"
$host_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${host_tpl_path}"

$http_tpl_path = "${icinga_path}/${http_tpl}.json"
$http_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${http_tpl}' ${lt}"
$http_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${http_tpl_path}"

$dns_tpl_path = "${icinga_path}/${dns_tpl}.json"
$dns_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${dns_tpl}' ${lt}"
$dns_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${dns_tpl_path}"

$master_tpl_path = "${icinga_path}/${master_tpl}.json"
$master_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${master_tpl}' ${lt}"
$master_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${master_tpl_path}"

$ipa_tpl_path = "${icinga_path}/${ipa_tpl}.json"
$ipa_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${ipa_tpl}' ${lt}"
$ipa_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${ipa_tpl_path}"

#Services Template Creation
$http_svc_tpl_path = "${icinga_path}/${http_svc_tpl_name}.json"
$http_svc_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_tpl_name}' ${lt}"
$http_svc_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$http_svc_tpl_path}"

$ping_svc_tpl_path = "${icinga_path}/${ping_svc_tpl_name}.json"
$ping_svc_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ping_svc_tpl_name}' ${lt}"
$ping_svc_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$ping_svc_tpl_path}"

$dns_svc_tpl_path  = "${icinga_path}/${dns_svc_tpl_name}.json"
$dns_svc_tpl_cond  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_tpl_name}' ${lt}"
$dns_svc_tpl_cmd   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$dns_svc_tpl_path}"

$master_svc_tpl_path = "${icinga_path}/${master_svc_tpl_name}.json"
$master_svc_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_tpl_name}' ${lt}"
$master_svc_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$master_svc_tpl_path}"

$ipa_svc_tpl_path = "${icinga_path}/${ipa_svc_tpl_name}.json"
$ipa_svc_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_tpl_name}' ${lt}"
$ipa_svc_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$ipa_svc_tpl_path}"

$disk_svc_tpl_path = "${icinga_path}/${disk_svc_tpl_name}.json"
$disk_svc_tpl_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${disk_svc_tpl_name}' ${lt}"
$disk_svc_tpl_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${$disk_svc_tpl_path}"

#Services Creation
$host_svc_path1 = "${icinga_path}/${host_svc_ping_name}.json"
$host_svc_cond1 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${host_svc_ping_name}&host=${host_tpl}' ${lt}"
$host_svc_cmd1  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${host_svc_path1}"
$host_svc_path2 = "${icinga_path}/${host_svc_disk_name}.json"
$host_svc_cond2 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${host_svc_disk_name}&host=${host_tpl}' ${lt}"
$host_svc_cmd2  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${host_svc_path2}"

$http_svc_path1 = "${icinga_path}/${http_svc_name}.json"
$http_svc_cond1 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_name}&host=${http_tpl}' ${lt}"
$http_svc_cmd1  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path1}"
$http_svc_path2 = "${icinga_path}/${http_svc_ping_name}.json"
$http_svc_cond2 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_ping_name}&host=${http_tpl}' ${lt}"
$http_svc_cmd2  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path2}"
$http_svc_path3 = "${icinga_path}/${http_svc_disk_name}.json"
$http_svc_cond3 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${http_svc_disk_name}&host=${http_tpl}' ${lt}"
$http_svc_cmd3  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${http_svc_path3}"

$dns_svc_path1  = "${icinga_path}/${dns_svc_name}.json"
$dns_svc_cond1  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_name}&host=${dns_tpl}' ${lt}"
$dns_svc_cmd1   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path1}"
$dns_svc_path2  = "${icinga_path}/${dns_svc_ping_name}.json"
$dns_svc_cond2  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_ping_name}&host=${dns_tpl}' ${lt}"
$dns_svc_cmd2   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path2}"
$dns_svc_path3  = "${icinga_path}/${dns_svc_disk_name}.json"
$dns_svc_cond3  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${dns_svc_disk_name}&host=${dns_tpl}' ${lt}"
$dns_svc_cmd3   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${dns_svc_path3}"

$master_svc_path1 = "${icinga_path}/${master_svc_dhcp_name}.json"
$master_svc_cond1 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_dhcp_name}&host=${master_tpl}' ${lt}"
$master_svc_cmd1  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path1}"
$master_svc_path2 = "${icinga_path}/${master_svc_ping_name}.json"
$master_svc_cond2 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_ping_name}&host=${master_tpl}' ${lt}"
$master_svc_cmd2  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path2}"
$master_svc_path3 = "${icinga_path}/${master_svc_disk_name}.json"
$master_svc_cond3 = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${master_svc_disk_name}&host=${master_tpl}' ${lt}"
$master_svc_cmd3  = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${master_svc_path3}"

$ipa_svc_path1  = "${icinga_path}/${ipa_svc_name}.json"
$ipa_svc_cond1  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_name}&host=${ipa_tpl}' ${lt}"
$ipa_svc_cmd1   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${ipa_svc_path1}"
$ipa_svc_path2  = "${icinga_path}/${ipa_svc_ping_name}.json"
$ipa_svc_cond2  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_ping_name}&host=${ipa_tpl}' ${lt}"
$ipa_svc_cmd2   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${ipa_svc_path2}"
$ipa_svc_path3  = "${icinga_path}/${ipa_svc_disk_name}.json"
$ipa_svc_cond3  = "${curl} '${credentials}' -H '${format}' -X GET '${url_svc}?name=${ipa_svc_disk_name}&host=${ipa_tpl}' ${lt}"
$ipa_svc_cmd3   = "${curl} '${credentials}' -H '${format}' -X POST '${url_svc}' -d @${ipa_svc_path3}"

#Master Host Creation
$addhost_path = "${icinga_path}/${master_fqdn}.json"
$addhost_cond = "${curl} '${credentials}' -H '${format}' -X GET '${url_host}?name=${master_fqdn}' ${lt}"
$addhost_cmd  = "${curl} '${credentials}' -H '${format}' -X POST '${url_host}' -d @${addhost_path}"

#Force Deploy pending requests
$deploy_cmd = "${curl} '${credentials}' -H '${format}' -X POST '${url}/config/deploy'"

#<---------END Variables Definition---------------->
#
#
#
#
#<---------------Clases definition----------------->
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
        port      => 5665,
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
  $relaod   = '; systemctl dameon-reload'
  $command1 = 'useradd -r -g icingaweb2 -d /var/lib/icingadirector -s /bin/false icingadirector'
  $command2 = 'install -d -o icingadirector -g icingaweb2 -m 0750 /var/lib/icingadirector'
  $command3 = "cp /usr/share/icingaweb2/modules/director/contrib/systemd/icinga-director.service /etc/systemd/system/${reload}"
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
##IcingaWeb PNP
  exec { 'git clone https://github.com/Icinga/icingaweb2-module-pnp.git pnp':
    cwd      => '/usr/share/icingaweb2/modules/',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    before   => Exec['icingacli module enable pnp'],
    onlyif   => ['test -d /usr/share/icingaweb2/modeules/pnp'],
  }
  exec { 'icingacli module enable pnp':
    cwd    => '/var/tmp/',
    path   => ['/sbin', '/usr/sbin', '/bin'],
    onlyif => ['test ! -f /etc/icingaweb2/enabledModules/pnp'],
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
#<-----------END Clases definition----------------->
#
#
#<---------Files Creation and deployement---------->

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
  file { $master_tpl_path:
    ensure  => 'present',
    content => $master_template,
    before  => Exec[$master_tpl_cmd],
  }
#Add dhcp template
  exec { $master_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_tpl_cond,
  }
#Create ipa file
  file { $ipa_tpl_path:
    ensure  => 'present',
    content => $ipa_template,
    before  => Exec[$ipa_tpl_cmd],
  }
#Add ipa template
  exec { $ipa_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ipa_tpl_cond,
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
  file { $master_svc_tpl_path:
    ensure  => 'present',
    content => $master_svc_tpl,
    before  => Exec[$master_svc_tpl_cmd],
  }
#Add http template
  exec { $master_svc_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_svc_tpl_cond,
  }
#Create dns template file 
  file { $dns_svc_tpl_path:
    ensure  => 'present',
    content => $dns_svc_tpl,
    before  => Exec[$dns_svc_tpl_cmd],
  }
#Add dns template
  exec { $dns_svc_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_svc_tpl_cond,
  }
#Create ipa template file 
  file { $ipa_svc_tpl_path:
    ensure  => 'present',
    content => $ipa_svc_tpl,
    before  => Exec[$ipa_svc_tpl_cmd],
  }
#Add ipa template
  exec { $ipa_svc_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ipa_svc_tpl_cond,
  }
#Create disk template file 
  file { $disk_svc_tpl_path:
    ensure  => 'present',
    content => $disk_svc_tpl,
    before  => Exec[$disk_svc_tpl_cmd],
  }
#Add disk template
  exec { $disk_svc_tpl_cmd:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $disk_svc_tpl_cond,
  }

##Services Definition
#Creates ping resource file for HostTemplate and PingServiceTemplate
  file { $host_svc_path1:
    ensure  => 'present',
    content => $host_svc1,
    before  => Exec[$host_svc_cmd1],
  }
#Adds ping resource file for HostTemplate and PingServiceTemplate
  exec { $host_svc_cmd1:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $host_svc_cond1,
  }
#Creates disk resource file for HostTemplate and DiskServiceTemplate
  file { $host_svc_path2:
    ensure  => 'present',
    content => $host_svc2,
    before  => Exec[$host_svc_cmd2],
  }
#Adds disk resource file for HostTemplate and DiskServiceTemplate
  exec { $host_svc_cmd2:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $host_svc_cond2,
  }

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
#Creates ping resource file for HttpTemplate and PingServiceTemplate
  file { $http_svc_path2:
    ensure  => 'present',
    content => $http_svc2,
    before  => Exec[$http_svc_cmd2],
  }
#Adds ping resource file for HttpTemplate and PingServiceTemplate
  exec { $http_svc_cmd2:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_svc_cond2,
  }
#Creates disk resource file for HttpTemplate and DiskServiceTemplate
  file { $http_svc_path3:
    ensure  => 'present',
    content => $http_svc3,
    before  => Exec[$http_svc_cmd3],
  }
#Adds disk resource file for HttpTemplate and DiskServiceTemplate
  exec { $http_svc_cmd3:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $http_svc_cond3,
  }

#Creates dhcp resource file for MasterTemplate and DhcpServiceTemplate
  file { $master_svc_path1:
    ensure  => 'present',
    content => $master_svc1,
    before  => Exec[$master_svc_cmd1],
  }
#Adds dhcp resource file for MasterTemplate and DhcpServiceTemplate
  exec { $master_svc_cmd1:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_svc_cond1,
  }
#Creates ping resource file for MasterTemplate and PingServiceTemplate
  file { $master_svc_path2:
    ensure  => 'present',
    content => $master_svc2,
    before  => Exec[$master_svc_cmd2],
  }
#Adds ping resource file for MasterTemplate and PingServiceTemplate
  exec { $master_svc_cmd2:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_svc_cond2,
  }
#Creates disk resource file for MasterTemplate and DiskServiceTemplate
  file { $master_svc_path3:
    ensure  => 'present',
    content => $master_svc3,
    before  => Exec[$master_svc_cmd3],
  }
#Adds disk resource file for MasterTemplate and DiskServiceTemplate
  exec { $master_svc_cmd3:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $master_svc_cond3,
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
#Creates ping resource file for DnsTemplate and PingServiceTemplate
  file { $dns_svc_path2:
    ensure  => 'present',
    content => $dns_svc2,
    before  => Exec[$dns_svc_cmd2],
  }
#Adds ping resource file for DnsTemplate and PingServiceTemplate
  exec { $dns_svc_cmd2:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_svc_cond2,
  }
#Creates disk resource file for DnsTemplate and DiskServiceTemplate
  file { $dns_svc_path3:
    ensure  => 'present',
    content => $dns_svc3,
    before  => Exec[$dns_svc_cmd3],
  }
#Adds disk resource file for DnsTemplate and DiskServiceTemplate
  exec { $dns_svc_cmd3:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $dns_svc_cond3,
  }

#Creates ipa resource file for IpaTemplate and IpaServiceTemplate
  file { $ipa_svc_path1:
    ensure  => 'present',
    content => $ipa_svc1,
    before  => Exec[$ipa_svc_cmd1],
  }
#Adds ipa resource file for IpaTemplate and IpaServiceTemplate
  exec { $ipa_svc_cmd1:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ipa_svc_cond1,
  }
#Creates ping resource file for IpaTemplate and PingServiceTemplate
  file { $ipa_svc_path2:
    ensure  => 'present',
    content => $ipa_svc2,
    before  => Exec[$dns_svc_cmd2],
  }
#Adds ping resource file for IpaTemplate and PingServiceTemplate
  exec { $ipa_svc_cmd2:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ipa_svc_cond2,
  }
#Creates disk resource file for IpaTemplate and DiskServiceTemplate
  file { $ipa_svc_path3:
    ensure  => 'present',
    content => $ipa_svc3,
    before  => Exec[$ipa_svc_cmd3],
  }
#Adds disk resource file for IpaTemplate and DiskServiceTemplate
  exec { $ipa_svc_cmd3:
    cwd      => $icinga_path,
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => $ipa_svc_cond3,
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
#<------END Files Creation and deployement--------->
}

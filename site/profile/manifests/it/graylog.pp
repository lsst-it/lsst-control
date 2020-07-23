# Graylog config
class profile::it::graylog {
  class { 'java' :
  package => 'java-1.8.0-openjdk',
    }
# I don't why but this exact config retured error initially.
# I had to specify version first with manage_package_repo to true
# Then change things back to original and it installed.    
class {'mongodb::globals':
  manage_package_repo => false,
  manage_package      => true,
  version             => '3.6.18-1.el7',
  }
class { 'mongodb::server':
  bind_ip => ['127.0.0.1'],
  }
$xms = lookup('elasticsearch_xms')
$xmx = lookup('elasticsearch_xmx')

class { 'elastic_stack::repo':
  version => 6,
  }

class { 'elasticsearch':
  version       => '6.3.1',
  manage_repo   => true,
    jvm_options => [
      "-Xms${xms}",
      "-Xmx${xmx}"
    ]
  }
elasticsearch::instance { 'graylog':
  config => {
    'cluster.name' => 'graylog',
    'network.host' => '127.0.0.1',
    }
  }
class { 'graylog::repository':
  version => '3.0'
}
#################################################################################################################
# Requirements for graylog::server
$ssl_config_dir = '/etc/graylog/server'

#TODO fine a better way of resolve this dependency
  file{ '/etc/graylog':
    ensure => directory
  }

  file{ $ssl_config_dir:
    ensure => directory
  }

$ssl_config_filename = 'openssl-graylog.cnf'
$graylog_canonical_name = lookup('canonical_name')
file { "${ssl_config_dir}/${ssl_config_filename}":
    ensure  => present,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => epp('profile/it/graylog_ssl_cfg.epp',
      {
      'country'           => lookup('country'),
      'state'             => lookup('state'),
      'locality'          => lookup('locality'),
      'organization'      => lookup('organization'),
      'division'          => lookup('division'),
      'canonical_name'    => lookup('canonical_name'),
      'server_ip'         => lookup('server_ip_address'),
      'alternative_dns_1' => lookup('alternative_dns_1'),
      }
    ),
    require => [File[$ssl_config_dir], File_line["Update Graylog's JAVA_OPTS"]],
  }

$certificate_duration = lookup('certificate_duration')
$ssl_key_algorithm = lookup('ssl_key_algorithm')
$ssl_keyout_filename = 'pkcs5-plain.pem'
$ssl_graylog_cert_filename = 'graylog-certificate.pem'
exec{ 'Create SSL certificate':
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    command => "openssl req -x509 -days ${certificate_duration} -nodes -newkey ${ssl_key_algorithm} 
    -config ${ssl_config_dir}/${ssl_config_filename} -keyout ${ssl_config_dir}/${ssl_keyout_filename} 
    -out ${ssl_config_dir}/${ssl_graylog_cert_filename}",
    onlyif  => 'test ! -f /etc/graylog/server/graylog-certificate.pem',
    require => [File["${ssl_config_dir}/${ssl_config_filename}"]]
}

# Convert PKCS5 into PKCS8 encrypted

$ssl_pkcs8_encrypted_filename = 'pkcs8-encrypted.pem'
$ssl_pkcs8_passout_phrase = lookup('ssl_passout_phrase')


exec{ 'Convert pkcs5 to pkcs8 encrypted' :
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    command => "openssl pkcs8 -in ${ssl_config_dir}/${ssl_keyout_filename} 
    -topk8 -out ${ssl_config_dir}/${ssl_pkcs8_encrypted_filename} -passout ${ssl_pkcs8_passout_phrase }",
    onlyif  => "test ! -f ${ssl_config_dir}/${ssl_pkcs8_encrypted_filename}",
    require => Exec['Create SSL certificate'],
  }

# Create a SSL Key.

$ssl_key_passout_phrase = lookup('ssl_key_passout_phrase')
$ssl_graylog_key_filename = 'graylog-key.pem'
exec{ 'Create graylog SSL key' :
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    command => "openssl pkcs8 -in ${ssl_config_dir}/${ssl_pkcs8_encrypted_filename} 
    -topk8 -passin ${ssl_pkcs8_passout_phrase } -out ${ssl_config_dir}/${ssl_graylog_key_filename} 
    -passout ${ssl_key_passout_phrase}",
    onlyif  => "test ! -f ${ssl_config_dir}/${ssl_graylog_key_filename}",
    require => Exec['Convert pkcs5 to pkcs8 encrypted'],
  }

# Update the current keytool to include also this self signed certificate

#Copy the current CA Cert into graylog's directory

$graylog_cacert_filename = 'graylog-cacerts'
exec{ "Copy JAVA cacerts into graylog's directory":
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    command => "cp /etc/pki/java/cacerts ${ssl_config_dir}/${graylog_cacert_filename}",
    onlyif  => "test ! -f ${ssl_config_dir}/${graylog_cacert_filename}"
  }

$ssl_graylog_cert_pass = lookup('ssl_graylog_cert_pass')
exec{ 'Update keytool' :
    path    => [ '/usr/bin', '/bin', '/usr/sbin' ],
    command => "keytool -noprompt -importcert -keystore ${ssl_config_dir}/${graylog_cacert_filename} 
    -storepass ${ssl_graylog_cert_pass} -alias graylog-self-signed -file ${ssl_config_dir}/${ssl_graylog_cert_filename}",
    onlyif  => "test -z $(keytool -keystore ${ssl_config_dir}/${graylog_cacert_filename} 
    -storepass ${ssl_graylog_cert_pass} -list | grep graylog-self-signed)",
    require => [Exec['Create graylog SSL key'], Exec["Copy JAVA cacerts into graylog's directory"]]
  }
$tls_password_array = split($ssl_key_passout_phrase, /:/)
$tls_cert_pass = $tls_password_array[1]
class { '::graylog::server':
  package_version => '3.0.0-12',
  config          => {
    password_secret           => lookup('graylog_server_password_secret'),    # Fill in your password secret
    root_password_sha2        => lookup('graylog_server_root_password_sha2'), # Fill in your root password hash
    web_listen_uri            => "https://${graylog_canonical_name}:9000/",
    rest_listen_uri           => "https://${graylog_canonical_name}:9000/api/",
    web_endpoint_uri          => "https://${graylog_canonical_name}:9000/api/",
    http_bind_address         => '0.0.0.0:9000',
    graylog_http_external_uri => "https://${graylog_canonical_name}:9000/",
    rest_enable_tls           => true,
    rest_tls_cert_file        => "${ssl_config_dir}/${ssl_graylog_cert_filename}",
    rest_tls_key_file         => "${ssl_config_dir}/${ssl_graylog_key_filename}",
    rest_tls_key_password     => "${tls_cert_pass}",
    web_enable_tls            => true,
    web_tls_cert_file         => "${ssl_config_dir}/${ssl_graylog_cert_filename}",
    web_tls_key_file          => "${ssl_config_dir}/${ssl_graylog_key_filename}",
    web_tls_key_password      => "${tls_cert_pass}"
  },
}

$graylog_java_opts = lookup('graylog_java_opts')
# Update graylog JAVA_OPTS to use the customized version including the self-signed cert.
  file_line{ "Update Graylog's JAVA_OPTS":
    ensure  => present,
    path    => '/etc/sysconfig/graylog-server',
    line    => "GRAYLOG_SERVER_JAVA_OPTS=\"${graylog_java_opts} -Djavax.net.ssl.trustStore=${ssl_config_dir}/${graylog_cacert_filename}\"",
    match   => 'GRAYLOG_SERVER_JAVA_OPTS*',
    require => Class['graylog::server']
  }
}

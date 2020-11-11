class profile::ccs::tomcat(
  Hash[String, Hash] $wars = {},
) {
  include ::nginx
  include profile::core::letsencrypt

  $version       = '9.0.36'
  $root_path     = '/opt/tomcat'
  $catalina_home = "${root_path}/apache-tomcat-${version}"
  $catalina_base = $catalina_home

  file { $root_path:
    ensure => directory,
  }

  tomcat::install { $catalina_home:
    source_url => "https://downloads.apache.org/tomcat/tomcat-9/v${version}/bin/apache-tomcat-${version}.tar.gz",
  }

  # XXX shockingly, puppetlabs-tomcat is not able to create an init script
  # without jsvc but does start up the service with inline shell commands.
  # XXX even more shockingly, the use_init param is broken as there is no way to.
  # set a service_name to be passed to tomcat::service.
  tomcat::instance { 'latest':
    catalina_home  => $catalina_home,
    manage_service => false,
  }

  # XXX https://stackoverflow.com/a/8247293
  # tomcat may take a moment to startup and create the correct directly paths. Basically, we are busy waiting on the tomcat service -- this is UGLY
  exec { 'wait for tomcat':
    command     => '/usr/bin/wget --spider --tries 10 --retry-connrefused --no-check-certificate http://localhost:8080',
    refreshonly => true,
    subscribe   => Service['tomcat'],
  }

  file { "${catalina_home}/conf/Catalina/localhost/mrtg.xml":
    ensure  => file,
    owner   => 'tomcat',
    group   => 'tomcat',
    mode    => '0664',
    content => '<Context docBase="/home/mrtg/comcam" path="/mrtg" />',
    require => Exec['wait for tomcat'],  # config dir creation
  }

  # XXX appears to be broken... hardwired to look at $catalina_base/conf/context.xml
  tomcat::config::context::manager { 'org.apache.catalina.valves.RemoteAddrValve':
    ensure        => 'absent',
    catalina_base => $catalina_base,
  }

  unless (empty($wars)) {
    $wars.each |String $n, Hash $conf| {
      tomcat::war { $n:
        * => $conf,
      }
    }
  }

  $service_unit = @("EOT")
    [Unit]
    Description=Tomcat 9 servlet container
    After=network.target

    [Service]
    Type=forking

    User=tomcat
    Group=tomcat

    Environment="JAVA_HOME=/usr/lib/jvm/jre"
    Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"

    Environment="CATALINA_BASE=${catalina_base}"
    Environment="CATALINA_HOME=${catalina_home}"
    Environment="CATALINA_PID=${catalina_home}/temp/tomcat.pid"
    Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

    ExecStart=${catalina_home}/bin/startup.sh
    ExecStop=${catalina_home}/bin/shutdown.sh

    [Install]
    WantedBy=multi-user.target
    | EOT

  systemd::unit_file { 'tomcat.service':
    content => $service_unit,
  }
  ~> service { 'tomcat':
    ensure    => 'running',
    enable    => true,
    subscribe => Tomcat::Instance['latest'],
  }

  $access_log = '/var/log/nginx/tomcat.access.log'
  $error_log  = '/var/log/nginx/tomcat.error.log'

  $fqdn    = $facts['networking']['fqdn']
  $le_root = "/etc/letsencrypt/live/${fqdn}"


  nginx::resource::upstream { 'tomcat':
    ensure  => present,
    members => {
      'localhost:8080' => {
        server => 'localhost',
        port   => 8080,
      },
    },
  }

  letsencrypt::certonly { $fqdn:
    plugin      => 'dns-route53',
    manage_cron => true,
  }
  ~> nginx::resource::server { 'tomcat-http':
    ensure                => present,
    listen_port           => 80,
    ssl                   => false,
    access_log            => $access_log,
    error_log             => $error_log,
    use_default_location  => true,
    proxy                 => 'http://tomcat',
    proxy_redirect        => 'default',
    proxy_connect_timeout => '150',
  }
}

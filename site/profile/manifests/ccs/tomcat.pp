# @summary
#   Install CCS tomcat based services
#
# @param wars
#   `tomcat::wars` resources to create.
#
# @param jars
#   Hash of jar files to install in lib directory: basename, source.
#
# @param trending_site
#   String giving web trending site (ir2, ats, comcam, maincamera)
#
# @param rest_etc_path
#   Path to CCS tomcat configuration directory.
#
# @param rest_url
#   String giving URL for the rest server.
#
# @param rest_user
#   Sensitive string giving username for the rest server.
#
# @param rest_pass
#   Sensitive string giving password for the rest server.
#
class profile::ccs::tomcat (
  Hash[String, Hash] $wars = {},
  Hash[String[1],String[1]] $jars = {},
  String[1] $trending_site = 'maincamera',
  String[1] $rest_etc_path = '/etc/ccs/tomcat',
  String[1] $rest_url      = 'lsstcam-db01:3306/ccsdbprod',
  Sensitive[String[1]] $rest_user = Sensitive('user'),
  Sensitive[String[1]] $rest_pass = Sensitive('pass'),
) {
  include nginx

  $version       = '9.0.53'
  $root_path     = '/opt/tomcat'
  $catalina_home = "${root_path}/apache-tomcat-${version}"
  $catalina_base = "${root_path}/catalina_base"
  $catalina_lib  = "${catalina_base}/lib"

  file { $root_path:
    ensure => directory,
  }

  tomcat::install { $catalina_home:
    source_url => "https://archive.apache.org/dist/tomcat/tomcat-9/v${version}/bin/apache-tomcat-${version}.tar.gz",
  }

  # XXX shockingly, puppetlabs-tomcat is not able to create an init script
  # without jsvc but does start up the service with inline shell commands.
  # XXX even more shockingly, the use_init param is broken as there is no way to.
  # set a service_name to be passed to tomcat::service.
  tomcat::instance { 'latest':
    catalina_home  => $catalina_home,
    catalina_base  => $catalina_base,
    manage_service => false,
  }

  # XXX https://stackoverflow.com/a/8247293
  # tomcat may take a moment to startup and create the correct directly paths. Basically, we are busy waiting on the tomcat service -- this is UGLY
  exec { 'wait for tomcat':
    command     => '/usr/bin/wget --spider --tries 10 --retry-connrefused --no-check-certificate http://localhost:8080/CCSWebTrending/',
    refreshonly => true,
    subscribe   => Service['tomcat'],
  }

  file { "${catalina_base}/conf/Catalina/localhost/mrtg.xml":
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
    catalina_base => $catalina_home,
  }

  # XXX work around for tomcat::config::context::manager
  # file { "${catalina_home}/webapps/host-manager/manager.xml":
  #   ensure  => file,
  #   owner   => 'tomcat',
  #   group   => 'tomcat',
  #   mode    => '0664',
  #   content => @(EOT)
  #     <?xml version="1.0" encoding="UTF-8"?>
  #     <Context docBase="${catalina.home}/webapps/manager"
  #            privileged="true" antiResourceLocking="false" >
  #     </Context>
  #     | EOT
  #   ,
  #   require => Exec['wait for tomcat'],  # config dir creation
  # }

  tomcat::config::properties::property { 'org.lsst.ccs.web.trending.default.site':
    catalina_base => $catalina_base,
    value         => $trending_site,
  }

  unless (empty($wars)) {
    $wars.each |String $n, Hash $conf| {
      tomcat::war { $n:
        catalina_base => $catalina_base,
        *             => $conf,
      }
    }
  }

  $jars.each |String $jfile, String $jsrc| {
    file { "${catalina_lib}/${jfile}":
      ensure  => file,
      owner   => 'tomcat',
      group   => 'tomcat',
      mode    => '0664',
      source  => $jsrc,
      require => Exec['wait for tomcat'],
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

    Environment="JAVA_HOME=/usr/java/default"
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

  nginx::resource::upstream { 'tomcat':
    ensure  => present,
    members => {
      'localhost:8080' => {
        server => 'localhost',
        port   => 8080,
      },
    },
  }

  nginx::resource::server { 'tomcat-http':
    ensure                => present,
    listen_port           => 80,
    ssl                   => false,
    access_log            => $access_log,
    error_log             => $error_log,
    use_default_location  => true,
    proxy                 => 'http://tomcat',
    proxy_redirect        => 'default',
    proxy_connect_timeout => '150',
    proxy_set_header      => ['Host $host', 'X-Real-IP $remote_addr', 'X-Forwarded-For $proxy_add_x_forwarded_for', 'X-Forwarded-Host $host', 'X-Forwarded-Proto $scheme', 'Proxy ""', 'Connection ""',],
    proxy_http_version    => '1.1',
    proxy_buffering       => 'off',
  }

  $adm_user = 'ccsadm'
  $adm_group = 'ccsadm'

  $etc_path = "${dirname($rest_etc_path)}"

  ensure_resources('file', {
      $etc_path => {
        ensure => directory,
        owner  => $adm_user,
        group  => $adm_group,
        mode   => '2775',
      },
      $rest_etc_path => {
        ensure => directory,
        owner  => 'tomcat',
        group  => $adm_group,
        mode   => '2770',
      },
  })

  ## Hash of templates and any arguments they take.
  $rest_etc_files = {
    'logging.properties' => {},
    'statusPersister.properties' => {
      'user' => $rest_user,
      'pass' => $rest_pass,
      'url'  => $rest_url,
    },
  }

  $rest_etc_files.each |$file, $epp_vars| {
    file { "${rest_etc_path}/${file}":
      ensure  => file,
      owner   => 'tomcat',
      group   => $adm_group,
      mode    => '0660',
      content => epp("${module_name}/ccs/tomcat/${file}.epp", $epp_vars),
    }
  }
}

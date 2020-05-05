class profile::ccs::tomcat {
  $root_path     = '/opt/tomcat'
  $catalina_home = "${root_path}/apache-tomcat-9.0.33"
  $catalina_base = $catalina_home

  file { $root_path:
    ensure => directory,
  }

  tomcat::install { $catalina_home:
    source_url => 'https://www-eu.apache.org/dist/tomcat/tomcat-9/v9.0.33/bin/apache-tomcat-9.0.33.tar.gz',
  }

  # XXX shockingly, puppetlabs-tomcat is not able to create an init script
  # without jsvc but does start up the service with inline shell commands.
  # XXX even more shockingly, the use_init param is broken as there is no way to.
  # set a service_name to be passed to tomcat::service.
  tomcat::instance { 'latest':
    catalina_home  => $catalina_home,
    manage_service => false,
  }

  # XXX appears to be broken... hardwired to look at $catalina_base/conf/context.xml
  tomcat::config::context::manager { 'org.apache.catalina.valves.RemoteAddrValve':
    ensure        => 'absent',
    catalina_base => $catalina_base,
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
}

class profile::ccs::tomcat {
  $base_path = '/opt/tomcat'

  file { $base_path:
    ensure => directory,
  }

  tomcat::install { "${base_path}/apache-tomcat-9.0.33":
    source_url => 'https://www-eu.apache.org/dist/tomcat/tomcat-9/v9.0.33/bin/apache-tomcat-9.0.33.tar.gz',
  }

  tomcat::instance { 'latest':
    catalina_home => "${base_path}/apache-tomcat-9.0.33",
  }

  # XXX appears to be broken... hardwired to look at $catalina_base/conf/context.xml
  tomcat::config::context::manager { 'org.apache.catalina.valves.RemoteAddrValve':
    ensure        => 'absent',
    catalina_base => "${base_path}/apache-tomcat-9.0.33",
  }
}

class profile::ccs::tomcat {

  tomcat::install { '/opt/tomcat/apache-tomcat-9.0.33':
    source_url => 'https://www-eu.apache.org/dist/tomcat/tomcat-9/v9.0.33/bin/apache-tomcat-9.0.33.tar.gz',
  }

  tomcat::instance { 'latest':
    catalina_home => '/opt/tomcat/apache-tomcat-9.0.33',
  }

  # XXX appears to be broken... hardwired to look at $catalina_base/conf/context.xml
  tomcat::config::context::manager { 'org.apache.catalina.valves.RemoteAddrValve':
    ensure        => 'absent',
    catalina_base => '/opt/tomcat/apache-tomcat-9.0.33',
  }
}

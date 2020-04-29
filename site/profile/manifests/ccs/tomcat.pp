class profile::ccs::tomcat {

  tomcat::install { '/opt/tomcat':
    source_url => 'https://www-eu.apache.org/dist/tomcat/tomcat-9/v9.0.33/bin/apache-tomcat-9.0.33.tar.gz',
  }

  tomcat::instance { 'latest':
    catalina_home => '/opt/tomcat',
  }

}

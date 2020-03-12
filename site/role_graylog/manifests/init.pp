class role_graylog {
  include java
  class { 'mongodb::globals':
    manage_package_repo => true,
    version             => '4.2.3',
  }
  -> class { 'mongodb::server':
    bind_ip => ['127.0.0.1'],
  }
  class { 'elasticsearch':
    version     => '6.6.0',
    manage_repo => true,
    require     => Class[
                    '::java',
                    ],
  }
  -> elasticsearch::instance { 'graylog':
    config          => {
      'cluster.name' => 'graylog',
      'network.host' => '127.0.0.1',
    }
  }
  class { 'graylog::repository':
    version         => '3.0'
  }
  -> class { 'graylog::server':
    package_version => '3.0.0-12',
    require         => Class['::java'],
  }
}


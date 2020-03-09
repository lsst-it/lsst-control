class graylog { 
  class { 'mongodb::globals':
    manage_package_repo => true,
  }->
  class { 'mongodb::server':
    bind_ip => ['127.0.0.1'],
  }
  class { 'elasticsearch':
    version      => '6.6.0',
    repo_version => '6.x',
    manage_repo  => true,
  }->
  elasticsearch::instance { 'graylog':
    config => {
      'cluster.name' => 'graylog',
      'network.host' => '127.0.0.1',
    }
  }
  class { 'graylog::repository':
    version => '3.0'
  }->
  class { 'graylog::server':
    package_version => '3.0.0-12',
  }
}

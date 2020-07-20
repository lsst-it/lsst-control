class profile::it::graylog {
  class { 'java' :
  package => 'java-1.8.0-openjdk',
    }
class {'mongodb::globals':
  manage_package_repo => false,
  manage_package      => true,
  }
class { 'mongodb::server':
  bind_ip => ['127.0.0.1'],
  }
$xms = lookup("elasticsearch_xms")
$xmx = lookup("elasticsearch_xmx")

class { 'elastic_stack::repo':
  version => 6,
  }

class { 'elasticsearch':
  version      => '6.3.1',
  manage_repo  => true,
    vm_options => [
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
}

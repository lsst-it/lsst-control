# This is the main class for the EFD, all the nodes uses this class, and its implementaiton depend on the hostname
class profile::ts::efd::ts_efd{

# $efd_user = lookup("ts::efd::user")

# $efd_user_pwd = lookup("ts::efd::user_pwd")

# $ts_sal_path = lookup("ts_sal::ts_sal_path")

# $ts_xml_subsystems = lookup("ts::efd::ts_xml_subsystems")

# $ts_efd_writers = lookup("ts::efd::ts_efd_writers")
  #include firewalld

  # Install MySQL Cluster

  $rpm_url = lookup('mysql_cluster_rpm')

  $rpm_basename = split($rpm_url, '/')[-1]

  $rpm_package_name = regsubst($rpm_basename, '.rpm', '')

  if ! defined(Package['epel-release']){
    package{'epel-release':
      ensure => installed,
    }
  }

  package{ $rpm_package_name:
    ensure   => installed,
    provider => yum,
    source   => $rpm_url
  }

  $mysql_cluster_repo = lookup('mysql_cluster_repo')

  ini_setting{ "Enabling repo ${mysql_cluster_repo}":
      ensure  => present,
      path    => '/etc/yum.repos.d/mysql-community.repo',
      section => $mysql_cluster_repo,
      setting => 'enabled',
      value   => 1,
      require => File[$mgmt_config_path]
  }

  ini_setting{ 'Desabling repo mysql80-community':
      ensure  => present,
      path    => '/etc/yum.repos.d/mysql-community.repo',
      section => 'mysql80-community',
      setting => 'enabled',
      value   => 0,
      require => File[$mgmt_config_path]
  }

  if $node_name == 'mgmt' {
    #TODO confirm if this is the right way to include classes from the same directory
    include profile::ts::efd::ts_efd_mgmt
  }elsif $node_name == 'data' {
    include profile::ts::efd::ts_efd_data
  }elsif $node_name == 'srv' {
    include profile::ts::efd::ts_efd_srv
    include profile::ts::efd::ts_efd_writers
    # include server profile

  }

  #Parameters for SAL module comes from HIERA
  # TODO ts_sal module is using Dave's provided python pre-compiled, however there is another way of installing python3.6 from epel.

}

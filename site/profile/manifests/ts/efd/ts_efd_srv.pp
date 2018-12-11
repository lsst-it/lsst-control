class profile::ts::efd::ts_efd_srv{

  package{ "mysql-cluster-community-server" :
    provider => yum,
    ensure => installed,
  }

  $mysql_server_config_path = lookup("mysql_cluster_server_config_path")

  $efdMysqlServerConfig_hash = lookup("mysql_server")

  # This block of code, will check the full path given and create all the directories if required plus the file
  ################################################################################
  # Last item will be the filename which is a file and is declared later
  $tmp = split($mysql_server_config_path, "/")
  $dir = $tmp[1,-2]
  $aux_dir = [""]
  $dir.each | $index, $sub_dir | {
      
    if join( $dir[ 1,$index] , "/" ) == "" {
      $aux_dir = "/"
    }else{
      $aux_dir = join( $aux_dir + $dir[1, $index] , "/")
    }
    file{ $aux_dir:
      ensure => directory,
    }
  }

  file{$mysql_server_config_path:
    ensure => present,
    require => Package["mysql-cluster-community-server"]
  }

  $mysql_cluster_dir = lookup("mysql_cluster_dir")

  file{$mysql_cluster_dir:
    ensure => directory,
    owner => mysql,
    group => mysql,
    notify => Exec["Mysql Initialization"],
    require => Package["mysql-cluster-community-server"]
  }

  exec{ "Mysql Initialization":
    path  => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'], 
    command => "mysqld --initialize-insecure",
    refreshonly => true,
    user => mysql,
    require => Package["mysql-cluster-community-server"],
    notify => Exec["Executing initial setup"]
  }

  $mysql_admin_password = lookup("ts::efd::mysql_admin_password")
  $efd_user = lookup("ts::efd::user")
	$efd_user_pwd = lookup("ts::efd::user_pwd")


  # this is initial provisioning
  # TODO Add an onlyif condition as well
  # TODO Add a timer to verify that the MYSQL server is online
  exec{ "Executing initial setup" :
    path  => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'], 
    command => "sleep 15; mysql -e \" ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysql_admin_password}'; CREATE DATABASE EFD; CREATE USER ${efd_user}@localhost IDENTIFIED BY '${efd_user_pwd}'; GRANT ALL PRIVILEGES ON EFD.* TO ${efd_user}@localhost ; \"  ",
    refreshonly => true,
    require => [Package["mysql-cluster-community-server"], Exec["Mysql Initialization"], Service["efd_mysqld"]]
  }

  ################################################################################

	$efdMysqlServerConfig_hash.each | $sections_key, $sections_hash| {
    
    $sections_hash.each | $config_key, $config_value| {

      if $config_value == "" {
        ini_setting { "Updating property in section ${sections_key} : ${config_key} in ${mysql_server_config_path} file":
          ensure  => present,
          path    => $mysql_server_config_path,
          section => $sections_key,
          setting => $config_key,
          value   => "",
          key_val_separator => " ",
          require => [File[$mysql_server_config_path], Package["mysql-cluster-community-server"]]
        }
      }else{
        ini_setting { "Updating property in section ${sections_key} : ${config_key} = ${config_value} in ${mysql_server_config_path} file":
          ensure  => present,
          path    => $mysql_server_config_path,
          section => $sections_key,
          setting => $config_key,
          value   => $config_value,
          require => [File[$mysql_server_config_path], Package["mysql-cluster-community-server"]]
        }
      }
    }
  }

  # Systemd unit creation
  $mysqld_systemd_unit = "/etc/systemd/system/efd_mysqld.service"

  file { $mysqld_systemd_unit:
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => epp('profile/ts/deafult_systemd_unit_template.epp', 
      { 'serviceDescription' => "EFD MySQL daemon",
        'serviceCommand' => "/sbin/mysqld --defaults-file=${mysql_server_config_path} --ndbcluster",
        'systemdUser' => 'mysql'
      }),
    notify => Exec["MYSQL Reload deamon"]
  }

  exec{ "MYSQL Reload deamon":
    path  => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'], 
    command => "systemctl daemon-reload",
    refreshonly => true,
  }

  service{ "efd_mysqld":
    ensure => running,
    require => File[$mysqld_systemd_unit]
  }

}

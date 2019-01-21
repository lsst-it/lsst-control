class profile::ts::efd::ts_efd_srv{

  package{ "mysql-cluster-community-server" :
    provider => yum,
    ensure => installed,
  }

  $efd_tiers = lookup("efd_tiers")

  $efd_tiers.each | $tier_key, $tier_hash | {

    $mysql_server_config_path = lookup("efd_tiers_vars.${tier_key}.mysql_cluster_server_config_path")

    $efdMysqlServerConfig_hash = $tier_hash["mysql_server"] 

    # This block of code, will check the full path given and create all the directories if required plus the file
    ################################################################################
    # Last item will be the filename which is a file and is declared later
    $tmp = split($mysql_server_config_path, "/")
    $dir = $tmp[1,-1]
    $aux_dir = [""]
    $dir.each | $index, $sub_dir | {
        
      if join( $dir[ 1,$index] , "/" ) == "" {
        $aux_dir = "/"
      }else{
        $aux_dir = join( $aux_dir + $dir[0, $index] , "/")
      }
      if ! defined( File[$aux_dir]){
        file{ $aux_dir:
          ensure => directory,
        }
      }
    }

    file{$mysql_server_config_path:
      ensure => present,
      owner => mysql,
      group => mysql,
      require => Package["mysql-cluster-community-server"]
    }

    $mysql_cluster_dir = lookup("efd_tiers_vars.${tier_key}.mysql_cluster_dir")

    $tmp_1 = split($mysql_cluster_dir, "/")
    $dir_1 = $tmp_1[1,-1]
    $aux_dir_1 = [""]
    $dir_1.each | $index, $sub_dir | {
      if join( $dir_1[ 1,$index] , "/" ) == "" {
        $aux_dir = "/"
      }else{
        $aux_dir = join( $aux_dir + $dir_1[0, $index] , "/")
      }
      if ! defined(File[$aux_dir]){
        file{ $aux_dir:
          ensure => directory,
        }
      }
    }

    file{ [ $mysql_cluster_dir, "${mysql_cluster_dir}/srv/" ] :
      ensure => directory,
      owner => mysql,
      group => mysql,
      seltype => mysqld_db_t,
      notify => Exec["Mysql Initialization - ${tier_key}"],
      require => Package["mysql-cluster-community-server"]
    }

    #############################################################################

    $mysql_cluster_datadir = lookup("efd_tiers_vars.${tier_key}.mysql_cluster_datadir")

    $tmp_2 = split($mysql_cluster_datadir, "/")
    $dir_2 = $tmp_2[1,-1]
    $aux_dir_2 = [""]
    $dir_2.each | $index, $sub_dir | {
      if join( $dir_2[ 1,$index] , "/" ) == "" {
        $aux_dir_2 = "/"
      }else{
        $aux_dir_2 = join( $aux_dir_2 + $dir_2[0, $index+1] , "/")
      }
      if ! defined(File[$aux_dir_2]){
        file{ $aux_dir_2:
          ensure => directory,
        }
      }
    }

    file{ "${mysql_cluster_datadir}/srv/":
      ensure => directory,
      owner => mysql,
      group => mysql,
      seltype => mysqld_db_t,
      require => File["${mysql_cluster_datadir}"]
    }

    ################################################################################

    file{ "/etc/my-${tier_key}.cnf":
      ensure => present,
    }

    # This is just in case someone try to start mysqld systemd unit, It will try to use the same socket as the efd_mysqld
    ini_setting { "Updating [mysqld] datadir=${mysql_cluster_datadir}/srv/ in /etc/my-${tier_key}.cnf":
      ensure  => present,
      path    => "/etc/my-${tier_key}.cnf",
      section => "mysqld",
      setting => "datadir",
      value   => "${mysql_cluster_datadir}/srv/",
      require => File["/etc/my-${tier_key}.cnf"]
    }

    # This is just in case someone try to start mysqld systemd unit, It will try to use the same socket as the efd_mysqld
    $efd_mysqld_socket = $efdMysqlServerConfig_hash["mysqld"]["socket"]

    ini_setting { "Updating [mysqld] socket=${efd_mysqld_socket} in /etc/my-${tier_key}.cnf":
      ensure  => present,
      path    => "/etc/my-${tier_key}.cnf",
      section => "mysqld",
      setting => "socket",
      value   => $efd_mysqld_socket,
      require => File["/etc/my-${tier_key}.cnf"]
    }

    ini_setting { "Updating [mysql] section socket=${efd_mysqld_socket} in /etc/my-${tier_key}.cnf":
      ensure  => present,
      path    => "/etc/my-${tier_key}.cnf",
      section => "mysql",
      setting => "socket",
      value   => $efd_mysqld_socket,
      require => File["/etc/my-${tier_key}.cnf"]
    }

    exec{ "Mysql Initialization - ${tier_key}":
      path  => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'], 
      command => "mysqld --user=mysql --initialize-insecure --datadir=${mysql_cluster_datadir}/srv/",
      refreshonly => true,
      require => [Package["mysql-cluster-community-server"],File[$mysql_cluster_dir]],
      notify => [Exec["Executing initial setup - ${tier_key}"], Exec["Adjust SELinux to allow MySQL - ${tier_key}"]]
    }

    exec{ "Adjust SELinux to allow MySQL - ${tier_key}":
      path  => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'], 
      refreshonly => true,
      require => File[$mysql_cluster_dir],
      command => "setsebool -P nis_enabled 1 ; setsebool -P mysql_connect_any 1",
      onlyif => "test ! -z $\"(which setsebool)\"" # This executes the command only if setsebool command exists
    }

    $mysql_admin_password = lookup("ts::efd::mysql_admin_password")
    $efd_user = lookup("ts::efd::user")
    $efd_user_pwd = lookup("ts::efd::user_pwd")
    $mysql_cluster_mysqld_port = lookup("efd_tiers_vars.${tier_key}.mysql_cluster_mysqld_port")

    # this is initial provisioning
    # TODO Add an onlyif condition as well
    # TODO Add a timer to verify that the MYSQL server is online
    exec{ "Executing initial setup - ${tier_key}" :
      path  => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'], 
      command => "sleep 10; mysql -P ${mysql_cluster_mysqld_port}  -e \" ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysql_admin_password}'; CREATE DATABASE EFD; CREATE USER ${efd_user}@localhost IDENTIFIED BY '${efd_user_pwd}'; GRANT ALL PRIVILEGES ON EFD.* TO ${efd_user}@localhost ; \" --socket=${efd_mysqld_socket} ",
      refreshonly => true,
      require => [Package["mysql-cluster-community-server"], Exec["Mysql Initialization - ${tier_key}"], Service["efd_mysqld_${tier_key}"], Ini_setting["Updating [mysql] section socket=${efd_mysqld_socket} in /etc/my-${tier_key}.cnf"]]
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
    $mysqld_systemd_unit_name = "efd_mysqld_${tier_key}"
    $mysqld_systemd_unit = "/etc/systemd/system/${mysqld_systemd_unit_name}.service"

    file { $mysqld_systemd_unit:
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => epp('profile/ts/deafult_systemd_unit_template.epp', 
        { 'serviceDescription' => "EFD MySQL daemon",
          'serviceCommand' => "/sbin/mysqld --defaults-file=${mysql_server_config_path} --ndbcluster --datadir=${mysql_cluster_datadir}/srv/",
          'systemdUser' => 'mysql'
        }),
      notify => Exec["MYSQL Reload deamon"]
    }

    service{ "${mysqld_systemd_unit_name}":
      ensure => running,
      require => File[$mysqld_systemd_unit]
    }
  }

  file{ "/etc/my.cnf":
    ensure => "link",
    target => "/etc/my-tier1.cnf",
    seltype => "mysqld_etc_t",
    require => File["/etc/my-tier1.cnf"]
  }


  exec{ "MYSQL Reload deamon":
    path  => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'], 
    command => "systemctl daemon-reload",
    refreshonly => true,
  }

}

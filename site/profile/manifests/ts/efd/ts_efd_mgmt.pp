class profile::ts::efd::ts_efd_mgmt{

  package{ "mysql-cluster-community-server":
    ensure => installed,
  }

  package{ "mysql-cluster-community-management-server":
    ensure => installed,
  }

  package{ "mysql-cluster-community-client":
    ensure => installed,
  }

  $mgmt_config_path = lookup("mysql_cluster_mgmt_config_path")

  # This block of code, will check the full path given and create all the directories if required
  ################################################################################
  # Last item will be the filename which is a file and is declared later
  $tmp = split($mgmt_config_path, "/")
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

  $mysql_cluster_dir = lookup("mysql_cluster_dir")

  file{$mgmt_config_path:
    ensure => present,
  }

  ################################################################################

  $efdMGMTConfig_hash = lookup("mgmt")

	$efdMGMTConfig_hash.each | $sections_key, $sections_hash| {
    
    $sections_hash.each | $config_key, $config_value| {
      ini_setting { "Updating property in section ${sections_key} : ${config_key} = ${config_value} in ${mgmt_config_path} file":
        ensure  => present,
        path    => $mgmt_config_path,
        section => $sections_key,
        setting => $config_key,
        value   => $config_value,
        require => File[$mgmt_config_path]
      }
    }
  }

  $ndb_mgmd_systemd_unit = "/etc/systemd/system/efd_ndb_mgmd.service"

  file { $ndb_mgmd_systemd_unit:
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => epp('profile/ts/deafult_systemd_unit_template.epp', 
      { 'serviceDescription' => "EFD Node DB Management daemon",
        'serviceCommand' => "/sbin/ndb_mgmd --config-file=${mgmt_config_path} --nodaemon",
        'systemdUser' => 'root'
      }),
    notify => Exec["NDB_MGMD Reload deamon"]
  }

  exec{ "NDB_MGMD Reload deamon":
    path  => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'], 
    command => "systemctl daemon-reload",
    refreshonly => true,
  }

  service{ "efd_ndb_mgmd":
    ensure => running,
    require => File[$ndb_mgmd_systemd_unit]
  }

}

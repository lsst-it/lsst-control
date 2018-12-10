class profile::ts::efd::ts_efd_data{

  $mgmt_datanode_config_path = lookup("mysql_cluster_datanode_config_path")

  # This block of code, will check the full path given and create all the directories if required plus the file
  ################################################################################
  # Last item will be the filename which is a file and is declared later
  $tmp = split($mgmt_datanode_config_path, "/")
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

  file{$mgmt_datanode_config_path:
    ensure => present,
    require => Package["mysql-cluster-community-data-node"]
  }

  ################################################################################
  $efdDataNodeConfig_hash = lookup("ndb_node")

  package{ "mysql-cluster-community-data-node" :
    provider => yum,
    ensure => installed,
  }

	$efdDataNodeConfig_hash.each | $sections_key, $sections_hash| {
    
    $sections_hash.each | $config_key, $config_value| {
      ini_setting { "Updating property in section ${sections_key} : ${config_key} = ${config_value} in ${mgmt_datanode_config_path} file":
        ensure  => present,
        path    => $mgmt_datanode_config_path,
        section => $sections_key,
        setting => $config_key,
        value   => $config_value,
        require => File[$mgmt_datanode_config_path]
      }
    }
  }

  $ndbd_systemd_unit = "/etc/systemd/system/efd_ndbd.service"

  file { $ndbd_systemd_unit:
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => epp('profile/ts/deafult_systemd_unit_template.epp', 
      { 'serviceDescription' => "EFD Data Node daemon",
        'serviceCommand' => "/sbin/ndbd --defaults-file=${mgmt_datanode_config_path} --nodaemon",
        'systemdUser' => 'root'
      }),
    notify => Exec["NDBD Reload deamon"]
  }

  exec{ "NDBD Reload deamon":
    path  => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'], 
    command => "systemctl daemon-reload",
    refreshonly => true,
  }

  service{ "efd_ndbd":
    ensure => running,
    require => File[$ndbd_systemd_unit]
  }

}

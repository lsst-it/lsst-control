class profile::ts::efd::ts_efd_data{

  package{ "mysql-cluster-community-data-node" :
    provider => yum,
    ensure => installed,
  }

  $efd_tiers = lookup("efd_tiers" )

  $efd_tiers.each | $tier_key, $tier_hash | {

    $mgmt_datanode_config_path = $tier_hash["mysql_cluster_datanode_config_path"]

    # This block of code, will check the full path given and create all the directories if required plus the file
    ################################################################################
    # Last item will be the filename which is a file and is declared later
    $tmp = split($mgmt_datanode_config_path, "/")
    $dir = $tmp[1,-2]
    $aux_dir = [""]
    $dir.each | $index, $sub_dir | {
      $aux_dir = join( $aux_dir + $dir[0,$index+1] , "/")
      if ! defined( File[$aux_dir]){
        file{ $aux_dir:
          ensure => directory,
        }
      }
    }

    file{$mgmt_datanode_config_path:
      ensure => present,
      require => Package["mysql-cluster-community-data-node"]
    }

    $mysql_cluster_datanode_datapath = $tier_hash["mysql_cluster_datanode_datapath"]
    $data_tmp = split($mysql_cluster_datanode_datapath, "/")
    $data_dir = $data_tmp[1,-1]
    $data_aux_dir = [""]
    $data_dir.each | $index, $sub_dir | {
      $data_aux_dir = join( $data_aux_dir + $data_dir[0,$index+1] , "/")
      if ! defined(File[$data_aux_dir]){
        file{ $data_aux_dir:
          ensure => directory,
          seltype => mysqld_db_t,
        }
      }
    }

    ################################################################################
    $efdDataNodeConfig_hash = $tier_hash["ndb_node"]

    $efdDataNodeConfig_hash.each | $sections_key, $sections_hash| {
      
      $sections_hash.each | $config_key, $config_value| {

        if $config_value == ""{
          ini_setting { "Updating property in section ${sections_key} : ${config_key} in ${mgmt_datanode_config_path} file":
            ensure  => present,
            path    => $mgmt_datanode_config_path,
            section => $sections_key,
            setting => $config_key,
            value   => "",
            key_val_separator => " ",
            require => File[$mgmt_datanode_config_path]
          }
        }else{
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
    }

    $ndbd_systemd_unit_name = "efd_ndbd_${tier_key}"
    $ndbd_systemd_unit = "/etc/systemd/system/${ndbd_systemd_unit_name}.service"

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

    service{ "${ndbd_systemd_unit_name}":
      ensure => running,
      require => File[$ndbd_systemd_unit]
    }

  }

  exec{ "NDBD Reload deamon":
    path  => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'], 
    command => "systemctl daemon-reload",
    refreshonly => true,
  }
}

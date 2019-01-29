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

  $efd_tiers = lookup("efd_tiers")

  $efd_tiers.each | $tier_key, $tier_hash | {
    #tier 1 -> hash
    $mgmt_config_path = lookup("efd_tiers_vars.${tier_key}.mysql_cluster_mgmt_config_path") 
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
      if ! defined(File[$aux_dir]){
        file{ $aux_dir:
          ensure => directory,
        }
      }
    }

    $mysql_cluster_dir = lookup("efd_tiers_vars.${tier_key}.mysql_cluster_dir")

    $tmp_1 = split($mysql_cluster_dir, "/")
    $dir_1 = $tmp_1[1,-1]
    $aux_dir_1 = [""]
    $dir_1.each | $index, $sub_dir | {
      if join( $dir_1[ 1,$index] , "/" ) == "" {
        $aux_dir_1 = "/"
      }else{
        $aux_dir_1 = join( $aux_dir_1 + $dir_1[0, $index+1] , "/")
      }
      notify{ " ${tier_key} ${index} subdir: ${aux_dir_1}": }
      if ! defined(File[$aux_dir_1]){
        file{ $aux_dir_1:
          ensure => directory,
        }
      }
    }

    $mysql_cluster_config_dir = "${mysql_cluster_dir}/mgmt/"

    file{ $mysql_cluster_config_dir:
      ensure => directory,
      owner => mysql,
      group => mysql,
      seltype => mysqld_db_t,
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

    file{ "${mysql_cluster_datadir}/mgmt/":
      ensure => directory,
      owner => mysql,
      group => mysql,
      seltype => mysqld_db_t,
      require => File["${mysql_cluster_datadir}"]
    }

    ################################################################################
    # Management configuration as String provided by hiera.
    # While mysql cluster uses not standard ini configuration file, the content 
    # can only be defined as String, because of duplicated sections to define each 
    # mysqld and ndbd servers.
    file{$mgmt_config_path:
      ensure => present,
      content => $tier_hash["mgmt"]
    }

    $ndb_mgmd_systemd_unit_name = "efd_ndb_mgmd_${tier_key}"
    $ndb_mgmd_systemd_unit = "/etc/systemd/system/${ndb_mgmd_systemd_unit_name}.service"

    file { $ndb_mgmd_systemd_unit:
      mode    => '0644',
      owner   => 'root',
      group   => 'root',
      content => epp('profile/ts/deafult_systemd_unit_template.epp', 
        { 'serviceDescription' => "[${tier_key}] EFD Node DB Management daemon",
          'serviceCommand' => "/sbin/ndb_mgmd --config-file=${mgmt_config_path} --nodaemon --config-dir=${mysql_cluster_config_dir}",
          'systemdUser' => 'root'
        }),
      notify => Exec["NDB_MGMD Reload deamon"]
    }

    service{ "${ndb_mgmd_systemd_unit_name}":
      ensure => running,
      require => File[$ndb_mgmd_systemd_unit]
    }
  }

  exec{ "NDB_MGMD Reload deamon":
    path  => [ '/usr/bin', '/bin', '/usr/sbin' , '/usr/local/bin'], 
    command => "systemctl daemon-reload",
    refreshonly => true,
  }
}

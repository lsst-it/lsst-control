# This is the main class for the EFD, all the nodes uses this class, and its implementaiton depend on the hostname
class profile::ts::efd::ts_efd{

  if $node_name == 'influxdb' {
    include efd::efd_writers
    include efd::efd_influxdb
  } elsif $node_name == 'mysql' {
    include efd::efd_writers
    include efd::efd_mysql
  } elsif $node_name == 'writers' {
    include efd::efd_writers
  } else {
    include efd
  }

}

# @summary
#   Installs and configures a MySQL server with an OpenVPN user having all privileges.
#
class profile::core::openvpndb {
  class { 'mysql::server':
    package_name     => 'mariadb-server',
    package_ensure   => '3:10.5.27-1.el9_5',
    root_password           => lookup('mysql::server::root_password'),
    remove_default_accounts => true,
    restart                 => true,
    override_options        => {
      'mysqld' => {
        'bind-address' => '0.0.0.0',
        'server-id'    => '1',
        'log_bin'      => '/var/log/mariadb/mariadb-bin.log',
      },
    },
  }

  mysql_user { 'openvpn@%':
    ensure        => 'present',
    password_hash => mysql::password(lookup('mysql_openvpn_password')),
    require       => Class['mysql::server'],
  }

  mysql_grant { 'openvpn@%/*.*':
    ensure        => 'present',
    user          => 'openvpn@%',
    table         => '*.*',
    privileges    => ['ALL'],
    require       => Mysql_user['openvpn@%'],
  }
}

class profile::it::influxdb {

	class {'influxdb::server':
		ensure                 => "present",
		service_enabled        => true,
		http_enabled           => true,
		http_auth_enabled      => true,
		http_log_enabled       => true,
		http_write_tracing     => false,
		http_pprof_enabled     => true,
		meta_bind_address      => ":8088",
		meta_http_bind_address => ":8091",
		http_bind_address      => ":8086",
		influxd_opts           => lookup("influxdb_opts"),
		http_https_enabled     => true,
		http_https_certificate => "/etc/ssl/influxdb.crt",
		http_https_private_key      => "/etc/ssl/influxdb.key"
	}

	exec{"Create Selfsigned cert":
		path => "/usr/bin/",
		command => "openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/influxdb.key -out /etc/ssl/influxdb.crt -days 365 -subj \"/C=CL/ST=Coquimbo/L=La Serena/O=LSST/CN=lsst.org\"",
		onlyif => "test ! -f /etc/ssl/influxdb.crt"
	}

	firewalld_port { 'InfluxDB Main Port':
		ensure   => present,
		port     => '8086',
		protocol => 'tcp',
		require => Service['firewalld'],
	}

	firewalld_port { 'InfluxDB Internodes Port':
		ensure   => present,
		port     => '8091',
		protocol => 'tcp',
		require => Service['firewalld'],
	}
	
	package{"net-snmp":
		ensure => "installed"
	}
	
	package{"net-snmp-utils":
		ensure => "installed"
	}
	
	$influx_admin_user = lookup("influx_admin_user")
	$influx_admin_passwd = lookup("influx_admin_passwd")
	
	exec{"Create admin user on influxdb":
		path    => ['/usr/bin','/usr/sbin'],
		command => "influx -execute \"CREATE USER ${influx_admin_user} WITH PASSWORD '${influx_admin_passwd}' WITH ALL PRIVILEGES\"",
		onlyif => "test $(influx -execute 'show databases' -username '${influx_admin_user}' -password '${influx_admin_passwd}' &> /dev/null; echo $? ) -eq 1"
	}

	$influx_telegraf_db_name = lookup("influx_telegraf_db_name")
	exec{"Create telegraf database on influxdb":
		path    => ['/usr/bin','/usr/sbin'],
		command => "influx -username '${influx_admin_user}' -password '${influx_admin_passwd}' -execute \"CREATE DATABASE ${influx_telegraf_db_name}\"",
		require => Exec["Create admin user on influxdb"],
		onlyif => "test $(influx -username '${influx_admin_user}' -password '${influx_admin_passwd}' -execute \"SHOW DATABASES\" | grep ${influx_telegraf_db_name} | wc -l ) -lt 1"
	}

	
	$influx_telegraf_user = lookup("influx_telegraf_user")
	$influx_telegraf_passwd = lookup("influx_telegraf_passwd")

	exec{"Create telegraf user on influxdb":
		path    => ['/usr/bin','/usr/sbin'],
		command => "influx  -username '${influx_admin_user}' -password '${influx_admin_passwd}' -execute \"CREATE USER ${influx_telegraf_user} WITH PASSWORD '${influx_telegraf_passwd}'\"",
		require => [Exec["Create admin user on influxdb"],Exec["Create telegraf database on influxdb"]],
		onlyif => "test $(influx -username '${influx_admin_user}' -password '${influx_admin_passwd}' -execute \"SHOW USERS\" | grep ${influx_telegraf_user} | wc -l ) -lt 1",
	}

	exec{"Grant WRITE access to telegraf db influxdb":
		path    => ['/usr/bin','/usr/sbin'],
		command => "influx  -username '${influx_admin_user}' -password '${influx_admin_passwd}' -execute \"GRANT WRITE ON ${influx_telegraf_db_name} TO ${influx_telegraf_user}\"",
		require => [Exec["Create admin user on influxdb"],Exec["Create telegraf database on influxdb"], Exec["Create telegraf user on influxdb"]],
		onlyif => "test $(influx -username '${influx_admin_user}' -password '${influx_admin_passwd}' -execute \"SHOW GRANTS FOR ${influx_telegraf_user}\" | grep -i ${influx_telegraf_db_name} | grep -i WRITE | wc -l ) -lt 1",
	}

	
	$influx_grafana_user = lookup("influx_grafana_user")
	$influx_grafana_passwd = lookup("influx_grafana_passwd")

	exec{"Create grafana user on influxdb":
		path    => ['/usr/bin','/usr/sbin'],
		command => "influx  -username '${influx_admin_user}' -password '${influx_admin_passwd}' -execute \"CREATE USER ${influx_grafana_user} WITH PASSWORD '${influx_grafana_passwd}'\"",
		require => [Exec["Create admin user on influxdb"],Exec["Create telegraf database on influxdb"]],
		onlyif => "test $(influx -username '${influx_admin_user}' -password '${influx_admin_passwd}' -execute \"SHOW USERS\" | grep ${influx_grafana_user} | wc -l ) -lt 1",
	}

	exec{"Grant READ access to telegraf db influxdb":
		path    => ['/usr/bin','/usr/sbin'],
		command => "influx  -username '${influx_admin_user}' -password '${influx_admin_passwd}' -execute \"GRANT READ ON ${influx_telegraf_db_name} TO ${influx_grafana_user}\"",
		require => [Exec["Create admin user on influxdb"],Exec["Create telegraf database on influxdb"], Exec["Create grafana user on influxdb"]],
		onlyif => "test $(influx -username '${influx_admin_user}' -password '${influx_admin_passwd}' -execute \"SHOW GRANTS FOR ${influx_grafana_user}\" | grep -i ${influx_telegraf_db_name} | grep -i READ | wc -l ) -lt 1",
	}
	# define the telegraf plugins to be used on influx for network monitoring
}

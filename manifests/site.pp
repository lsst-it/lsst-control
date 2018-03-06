node default {
	file { '/root/README' :
		ensure => file,
		content => "Welcome to ${fqdn}, this is a default server, uptime about ${system_uptime}\n",
	}
}

node /^puppet-master/ {
	include role::master_server
	file { '/root/master-README' :
		ensure => file,
	}
}

node /^dm-dev-farm/ {
	include role::dm::dm_header_service
}

node /^ts-sw-env/ {
	include role::ts::ts_dev_env_basic
}

node /^ts-sw-container/ {
	include role::ts::ts_sw_env_container
}

node /^ats-shutter-hcu/{
	include role::ccs::ats_shutter_hcu
}

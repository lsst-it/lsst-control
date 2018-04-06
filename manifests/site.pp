#TODO This have to be changed by an ENC script

node default {
	include role::default
}

node /^puppet-master/ {
	include role::master_server
	file { '/root/master-README' :
		ensure => file,
	}
}

node /^dm-hs/ {
	include role::dm::dm_header_service
}

node /^ts-sw-env/ {
	include role::ts::ts_dev_env_basic
}

node /^ts-visitsim/ {
	include role::ts::ts_sw_env_container
}

node /^ats-shutter-hcu/{
	include role::ccs::ats_shutter_hcu
}

node /^ts-efd/ {
	include role::ts::efd
}

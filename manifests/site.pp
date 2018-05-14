#TODO This have to be changed by an ENC script

node default {
	include role::default
}

node /^puppet-master/ {
	include role::it::puppet_master
}

node /^dm-hs/ {
	include role::dm::dm_header_service
}

node /^ts-sw-env/ {
	include role::ts::ts_dev_env_basic
}

node /^ts-visitsim/ {
	include role::ts::ts_visit_simulator
}

node /^ats-shutter-hcu/{
	include role::ccs::ats_shutter_hcu
}

node /^ts-efd/ {
	include role::ts::efd
}

node /^ts-intcluster/{
	include role::ts::ts_intcluster
}

node /^tcs-dome/{
	include role::ts::ts_dome
}
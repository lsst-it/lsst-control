#TODO This have to be changed by an ENC script

node default {
	include role::default
}

node /puppet-master/ {
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

node /tcs-dome/{
	include role::ts::ts_dome
}

node /tcs-rotator/{
	include role::ts::ts_rotator
}

node /influxdb/{
	include role::it::influxdb
}

node /grafana/{
	include role::it::grafana
}

node /graylog/{
	include role::it::graylog
}

node /gs-dhcp/{
	include role::it::gs_dhcp
}
/*
node /gs-it-slave/{
	include role::it::gs_slave
}

node /gs-it-failover/{
	include role::it::gs_failover
}
*/
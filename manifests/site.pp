#TODO This have to be changed by an ENC script

node default {
	include role::default
}

node /puppet-master/ {
	include role::it::puppet_master
}

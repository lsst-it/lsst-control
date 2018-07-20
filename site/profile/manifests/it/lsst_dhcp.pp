class profile::it::lsst_dhcp{
	class { 'dhcp':
		service_ensure => running,
		dnsdomain      => lookup("dnsdomains"),
		nameservers  => lookup("nameservers"),
		ntpservers   => lookup("ntpservers"),
		interfaces   => lookup("dhcp_interfaces"),
		#dnsupdatekey => '/etc/bind/keys.d/rndc.key',
		#dnskeyname   => 'rndc-key',
		#require      => Bind::Key['rndc-key'],
		#pxeserver    => '10.0.1.50',
		#pxefilename  => 'pxelinux.0',
		omapi_port   => 7911,
		dhcp_conf_extra => lookup("failover_configuration")
	}
	
	#iterate over an array of zones. Use a list of hash, listing every network defined and then on every line a hash
	$dhcp_pools = lookup("dhcp_pools")
	notice($dhcp_pools)
	$dhcp_pools.each | $pool | {
		dhcp::pool{ "${pool['domain']}":
			network => "${pool['values']["network"]}",
			mask    => "${pool['values']["mask"]}",
			range   => $pool['values']["range"],
			gateway => "${pool['values']["gateway"]}",
		}
	
	}
}
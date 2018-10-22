class profile::it::gs_dhcp{
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
		extra_config => [lookup("failover_configuration")],
		#extra_config => ["dummy_config 1" , "dummy_config 2"],
		dhcp_conf_extra => "INTERNAL_TEMPLATE",
		pools => lookup("dhcp_pools"),
		ignoredsubnets => lookup("ignored_subnets")
	}
}
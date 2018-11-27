class profile::it::gs_dhcp{
	class { 'dhcp':
		service_ensure => running,
		dnsdomain      => lookup("dnsdomain"),
		dnssearchdomains => lookup("dnssearchdomains"),
		nameservers  => lookup("nameservers"),
		ntpservers   => lookup("ntpservers"),
		interfaces   => lookup("dhcp_interfaces"), # This interface is later configured in /etc/systemd/system/dhcpd.service
		omapi_port   => 7911,
		extra_config => [lookup("failover_configuration")],
		dhcp_conf_extra => "INTERNAL_TEMPLATE",
		pools => lookup("dhcp_pools"),
		ignoredsubnets => lookup("ignored_subnets")
	}
}

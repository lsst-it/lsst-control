# Role used by DHCP servers
class role::it::gs_dhcp{
  include profile::default
  include profile::it::gs_dhcp
}

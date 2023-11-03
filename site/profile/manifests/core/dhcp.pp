# @summary
#   Include dhcp class only if dhcp::interfaces is defined in hiera
#
class profile::core::dhcp {
  $interfaces = lookup('dhcp::interfaces', Array[String], undef, [])
  if $interfaces != [] {
    include dhcp
  }
}

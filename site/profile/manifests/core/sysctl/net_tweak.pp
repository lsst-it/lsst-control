# @summary
#   Tweak Network settings via sysctls.

class profile::core::sysctl::net_tweak {
  $file = '/etc/sysctl.d/45-net_tweak.conf'

  sysctl::value {
    default:
      target => $file,
      ;
   'net.ipv4.tcp_rmem':
      value => "4096 87380 536870912",
       ;
    'net.ipv4.tcp_wmem':
      value => "4096 65536 536870912",
       ;
    'net.ipv4.tcp_slow_start_after_idle':
      value => 1,
  }
}

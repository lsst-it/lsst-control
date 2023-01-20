# @summary
#   Common functionality needed by rke on kubernetes nodes.
#
# @param enable_dhcp
#   Enable CNI dhcp plugin
#
# @param keytab_base64
#   base64 encoded krb5 keytab
#
# @param version
#   Version of rke utility to install
#
class profile::core::rke (
  Boolean                        $enable_dhcp   = false,
  Optional[Sensitive[String[1]]] $keytab_base64 = undef,
  String                         $version       = '1.3.3',
) {
  include kmod

  $user = 'rke'
  $uid  = 75500

  if $enable_dhcp {
    include cni::plugins
    include cni::plugins::dhcp
  }

  if $keytab_base64 {
    profile::util::keytab { $user:
      uid           => $uid,
      keytab_base64 => $keytab_base64,
      require       => Class[easy_ipa], # ipa must be setup to use the rke user
    }
  }

  vcsrepo { "/home/${user}/k8s-cookbook":
    ensure             => present,
    provider           => git,
    source             => 'https://github.com/lsst-it/k8s-cookbook.git',
    keep_local_changes => true,
    user               => $user,
    owner              => $user,
    group              => $user,
    require            => Class[easy_ipa], # ipa must be setup to use the rke user
  }

  $rke_checksum = $version ? {
    '1.3.3'  => '61088847d80292f305e233b7dff4ac8e47fefdd726e5245052450bf05da844aa',
    '1.3.6'  => 'c02a8dd7405e3729e004bb1d551fda4c1437f5e0e8279ea67efba8056c0d4898',
    '1.3.12' => '579da2206aec09cadccd8d6f4818861e78a256b6ae550a229335e500a472bd50',
    '1.4.1'  => '0db4be307e64549fe2e72b955562df52335b9895cc7ec838927991403f86c7c2',
    default  => undef,
  }
  unless ($rke_checksum) {
    fail("Unknown checksum for rke version: ${version}")
  }

  class { 'rke':
    version  => $version,
    checksum => $rke_checksum,
  }

  kmod::load { 'br_netfilter': }
  -> sysctl::value { 'net.bridge.bridge-nf-call-iptables':
    value  => 1,
    target => '/etc/sysctl.d/80-rke.conf',
  }
  -> Class['docker']
}

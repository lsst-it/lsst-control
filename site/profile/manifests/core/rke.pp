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
  String                         $version       = '1.5.8',
) {
  include kmod
  require ipa

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
      require       => Class['ipa'], # ipa must be setup to use the rke user
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
    require            => Class['ipa'], # ipa must be setup to use the rke user
  }

  $rke_checksum = $version ? {
    '1.3.12'    => '579da2206aec09cadccd8d6f4818861e78a256b6ae550a229335e500a472bd50',
    '1.4.6'     => '12d8fee6f759eac64b3981ef2822353993328f2f839ac88b3739bfec0b9d818c',
    '1.5.8'     => 'f691a33b59db48485e819d89773f2d634e347e9197f4bb6b03270b192bd9786d',
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

  sysctl::value { 'fs.inotify.max_user_instances':
    value  => 104857,
    target => '/etc/sysctl.d/80-rke.conf',
  }
  sysctl::value { 'fs.inotify.max_user_watches':
    value  => 1048576,
    target => '/etc/sysctl.d/80-rke.conf',
  }
}

# @summary
#   Common functionality needed by rke on kubernetes nodes.
#
# @param keytab_base64
#   base64 encoded krb5 keytab
#
# @param version
#   Version of rke utility to install
#
class profile::core::rke (
  Optional[Sensitive[String[1]]] $keytab_base64 = undef,
  String                         $version       = '1.5.10',
) {
  include kmod
  require ipa

  $user = 'rke'
  $uid  = 75500

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
    '1.5.8'      => 'f691a33b59db48485e819d89773f2d634e347e9197f4bb6b03270b192bd9786d',
    '1.5.9'      => '1d31248135c2d0ef0c3606313d80bd27a199b98567a053036b9e49e13827f54b',
    '1.5.10'     => 'cd5d3e8cd77f955015981751c30022cead0bd78f14216fcd1c827c6a7e5cc26e',
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

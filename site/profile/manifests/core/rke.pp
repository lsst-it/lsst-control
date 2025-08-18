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
  String                         $version       = '1.7.8',
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
    '1.6.5'      => '80694373496abd5033cb97c2512f2c36c933d301179881e1d28bf7b78efab3e7',
    '1.7.6'      => 'a6ef89ac3042e066b0596cb38d5bff0192b84a7d4b6ed5b14cddc4bcfd5c9cd9',
    '1.7.7'      => '4317d54ed5251d71c82b631083907c526dc74808941deebc392369108b7a4b10',
    '1.7.8'      => '9494448f684ab0f3f79c62aa9736cd718743ad94e78a291f49eafec8bc71abde',
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

# @summary
#   Install Helm
#
# @param version
#   Version to install.
#
# XXX consider moving the checksum lookup into lsst/helm_binary as a helper class.
#
class profile::core::helm (
  String $version = '3.5.4',
) {
  $rke_checksum = $version ? {
    '3.7.2' => '4ae30e48966aba5f807a4e140dad6736ee1a392940101e4d79ffb4ee86200a9e',
    '3.6.3' => '07c100849925623dc1913209cd1a30f0a9b80a5b4d6ff2153c609d11b043e262',
    '3.5.4' => 'a8ddb4e30435b5fd45308ecce5eaad676d64a5de9c89660b56face3fe990b318',
    '3.10.3' => '950439759ece902157cf915b209b8d694e6f675eaab5099fb7894f30eeaee9a2',
    default => undef,
  }
  unless ($rke_checksum) {
    fail("Unknown checksum for helm version: ${version}")
  }

  class { 'helm_binary':
    version  => $version,
    checksum => $rke_checksum,
  }
}

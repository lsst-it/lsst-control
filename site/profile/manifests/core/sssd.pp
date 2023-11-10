# @summary
#   Common functionality needed by standard nodes.
#
class profile::core::sssd {
  require ipa
  contain sssd

  Class['ipa'] -> Class['sssd']

  if fact('os.family') == 'RedHat' {
    # disable sssd socket activation and services which should be started by
    # sssd
    [
      'sssd-autofs',
      'sssd-autofs.socket',
      'sssd-kcm',
      'sssd-kcm.socket',
      'sssd-nss',
      'sssd-nss.socket',
      'sssd-pac',
      'sssd-pac.socket',
      'sssd-pam',
      'sssd-pam-priv.socket',
      'sssd-pam.socket',
      'sssd-ssh',
      'sssd-ssh.socket',
      'sssd-sudo',
      'sssd-sudo.socket',
    ].each |String $unit| {
      service { $unit:
        ensure  => stopped,
        enable  => false,
        require => Class['sssd'],
      }
    }
  }
}

# @summary
#   Manage host kerberos configuration
#
class profile::core::krb5 {
  require ipa
  include mit_krb5

  # run ipa-install-* script before trying to managing krb5.conf
  Class['ipa'] -> Class['mit_krb5']

  # create /etc/krb5.conf.d files only on EL8+
  unless fact('os.family') == 'RedHat' and fact('os.release.major') == '7' {
    file { '/etc/krb5.conf.d/crypto-policies':
      ensure => link,
      owner  => 'root',
      group  => 'root',
      target => '/etc/crypto-policies/back-ends/krb5.config',
    }

    file { '/etc/krb5.conf.d/freeipa':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      # lint:ignore:strict_indent
      content => @(CONTENT),
        [libdefaults]
            spake_preauth_groups = edwards25519
        | CONTENT
      # lint:endignore
    }
  }
}

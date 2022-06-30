# @summary
#   Plugin to reset IPA password through the Web UI
#
# @param keytab_base64
#   base64 encoded krb5 keytab for the iip user
#

class profile::core::ipa_pwd_reset (
  String $keytab_base64,
) {

  $yum_packages = [
    'python2-pip',
    'python-virtualenv',
    'git-core',
    'redis',
  ]
  # $init_virtualenv = @(VIRTUALENV)
  #   cd /opt/IPAPasswordReset/
  #   virtualenv-3 --system-site-packages ./virtualenv
  #   . ./virtualenv/bin/activate
  #   pip install -r requirements.txt
  # | VIRTUALENV

  package { $yum_packages:
    ensure => 'present'
  }
  file { '/opt/IPAPasswordReset':
    ensure => directory
  }
  -> file { '/opt/IPAPasswordReset/ldap-passwd-reset.keytab':
    ensure  => present,
    content => base64('decode', $keytab_base64),
    mode    => '0600',
    owner   => 'ldap-passwd-reset',
    group   => 'ldap-passwd-reset',
  }
  # -> exec { $init_virtualenv:
  #   cwd     => '/var/tmp/',
  #   path    => ['/sbin', '/usr/sbin', '/bin'],
  #   onlyif  => ['test ! -d /opt/IPAPasswordReset/virtualenv'],
  #   require => Packages[$yum_packages],
  # }
}

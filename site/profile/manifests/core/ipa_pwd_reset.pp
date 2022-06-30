# @summary
#   Plugin to reset IPA password through the Web UI
#
# @param keytab_base64
#   base64 encoded krb5 keytab for the iip user
#

class profile::core::ipa_pwd_reset (
  String $keytab_base64,
) {
  include ::redis

  #  Install required packages
  $yum_packages = [
    'python2-pip',
    'python-virtualenv',
    'git-core',
  ]

  # Initialize Virtenv
  $init_virtualenv = @(VIRTUALENV)
    cd /opt/IPAPasswordReset/
    virtualenv --system-site-packages ./virtualenv
    . ./virtualenv/bin/activate
    pip install -r requirements.txt
    | VIRTUALENV

  # HTTP Content
  $ipa_reset_http = @(HTTP)
    <Location "/reset">
      RedirectMatch 301 ^/reset$ /reset/
    </Location>

    <Location "/reset/">
      ProxyPass "http://127.0.0.1:8000/reset/"
    </Location>
    | HTTP

  #  Install packages
  package { $yum_packages:
    ensure => 'present'
  }

  #  Declare reset interface
  file { '/etc/httpd/conf.d/ipa-password-reset.conf':
    ensure  => present,
    mode    => '0644',
    content => $ipa_reset_http,
    notify  => Service['httpd']
  }

  #  Create folder, generate keytab and deploy virtenv
  file { '/opt/IPAPasswordReset':
    ensure => directory
  }
  -> vcsrepo { '/opt/IPAPasswordReset/':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/larrabee/freeipa-password-reset.git',
  }
  -> file { '/opt/IPAPasswordReset/ldap-passwd-reset.keytab':
    ensure  => present,
    content => base64('decode', $keytab_base64),
    mode    => '0600',
    owner   => 'ldap-passwd-reset',
    group   => 'ldap-passwd-reset',
  }
  -> exec { $init_virtualenv:
    cwd     => '/var/tmp/',
    path    => ['/sbin', '/usr/sbin', '/bin'],
    onlyif  => ['test ! -f /opt/IPAPasswordReset/virtualenv/pip-selfcheck.json'],
    require => Package[$yum_packages],
  }
}

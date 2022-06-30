# @summary
#   Plugin to reset IPA password through the Web UI
#
# @param keytab_base64
#   base64 encoded krb5 keytab for the iip user
#

class profile::core::ipa_pwd_reset (
  String $keytab_base64,
  String $secret_key,
  String $ldap_user,
) {
  include ::redis

  $keytab_path = '/opt/IPAPasswordReset'
  $keytab_path_settings = "${keytab_path}/PasswordReset/PasswordReset"
  #  Install required packages
  $yum_packages = [
    'python2-pip',
    'python-virtualenv',
    'git-core',
  ]

  # Initialize Virtenv
  $init_virtualenv = @("VIRTUALENV")
    cd ${keytab_path}
    virtualenv --system-site-packages ./virtualenv
    . ./virtualenv/bin/activate
    pip install -r requirements.txt
    systemctl daemon-reload
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

  #  Modify ldap-password-reset settings.py
  $ldap_setting = @("SETTINGS")
    sed 's/^SECRET_KEY/SECRET_KEY=\"${secret_key}\"/g' ${keytab_path_settings}/settings.py.example > ${keytab_path_settings}/temp.py
    sed -i '174,197d' ${keytab_path_settings}/temp.py
    sed -i '144,157d' ${keytab_path_settings}/temp.py
    | SETTINGS

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
  file { $keytab_path:
    ensure => directory
  }
  -> vcsrepo { $keytab_path:
    ensure   => present,
    provider => git,
    source   => 'https://github.com/larrabee/freeipa-password-reset.git',
  }
  -> file { "/etc/systemd/system/${ldap_user}.service":
    mode   => '0644',
    owner  => 'root',
    group  => 'root',
    source => "file://${keytab_path}/service/${ldap_user}.service"
  }
  -> file { "${keytab_path}/${ldap_user}.keytab":
    ensure  => present,
    content => base64('decode', $keytab_base64),
    mode    => '0600',
    owner   => $ldap_user,
    group   => $ldap_user,
  }
  -> exec { $init_virtualenv:
    cwd     => '/var/tmp/',
    path    => ['/sbin', '/usr/sbin', '/bin'],
    onlyif  => ["test ! -d ${keytab_path}/virtualenv"],
    require => Package[$yum_packages],
  }
  -> service { "${ldap_user}.service":
    ensure => 'running',
  }
  -> exec { $ldap_setting:
    cwd    => '/var/tmp/',
    path   => ['/sbin', '/usr/sbin', '/bin'],
    onlyif => ["test ! -f  ${keytab_path_settings}/temp.py"],
  }
}

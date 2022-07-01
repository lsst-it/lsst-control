# @summary
#   Plugin to reset IPA password through the Web UI
#
# @param keytab_base64
#   base64 encoded krb5 keytab for the ldap-passwd-reset user
#
# @param secret_key
#   Random key for encryption purposes
#
# @param ldap_user
#   AD user for email delivery
#
# @param ldap_pwd
#   AD user's password for email delivery
#

class profile::core::ipa_pwd_reset (
  String $keytab_base64,
  String $secret_key,
  String $ldap_user,
  String $ldap_pwd,
) {
  include redis

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
    sed 's/^SECRET_KEY.*/SECRET_KEY=\"${secret_key}\"/g' ${keytab_path_settings}/settings.py.example > ${keytab_path_settings}/settings.py
    sed -i '174,197d' ${keytab_path_settings}/settings.py
    sed -i '144,157d' ${keytab_path_settings}/settings.py
    sed -i 's/            "msg_template.*/            "msg_template": "Your one-time token is: {0} \\nDo not share the token with anyone. The token has a duration of 60min.\\n\\nBest RegardsnRubinObs IT",/g' ${keytab_path_settings}/settings.py
    sed -i 's/            "msg_subject.*/            "msg_subject": "RubinObs IPA password reset code",/g' ${keytab_path_settings}/settings.py
    sed -i 's/            "smtp_from.*/            "smtp_from": "ipa-passwd-reset@lsst.org",/g' ${keytab_path_settings}/settings.py
    sed -i 's/            "smtp_user.*/            "smtp_user": "ipa-passwd-reset@lsst.local",/g' ${keytab_path_settings}/settings.py
    sed -i 's/            "smtp_pass.*/            "smtp_pass": "${ldap_pwd}",/g' ${keytab_path_settings}/settings.py
    sed -i 's/            "smtp_server_addr.*/            "smtp_server_addr": "endeavour.lsst.org",/g' ${keytab_path_settings}/settings.py
    sed -i 's/            "smtp_server_port.*/            "smtp_server_addr": 587,/g' ${keytab_path_settings}/settings.py
    sed -i 's/            "smtp_server_tls.*/            "smtp_server_addr": True,/g' ${keytab_path_settings}/settings.py
    sed -i 's/        "enabled.*/        "enabled": True,/g' ${keytab_path_settings}/settings.py
    | SETTINGS

  #  'ldap-password-reset ' Service Content
  $ldap_service = @("SERVICE")
    [Unit]
    Description=FreeIPA Password Reset Service
    After=network.target remote-fs.target

    [Service]
    Type=simple
    User=ldap-passwd-reset
    Group=ldap-passwd-reset
    WorkingDirectory=${keytab_path_settings}/
    ExecStart=${keytab_path}/virtualenv/bin/python ${keytab_path}/PasswordReset/manage.py runserver
    Restart=always
    RestartSec=20
    PrivateTmp=true

    [Install]
    WantedBy=multi-user.target
    |SERVICE
  #  Install packages
  package { $yum_packages:
    ensure => 'present',
  }

  #  Declare reset interface
  file { '/etc/httpd/conf.d/ipa-password-reset.conf':
    ensure  => file,
    mode    => '0644',
    content => $ipa_reset_http,
    notify  => Service['httpd'],
  }

  #  Create folder, generate keytab and deploy virtenv
  file { $keytab_path:
    ensure => directory,
  }
  -> vcsrepo { $keytab_path:
    ensure   => present,
    provider => git,
    source   => 'https://github.com/larrabee/freeipa-password-reset.git',
  }
  -> exec { $init_virtualenv:
    cwd      => '/var/tmp/',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    onlyif   => ["test ! -d ${keytab_path}/virtualenv"],
    loglevel => debug,
    require  => Package[$yum_packages],
  }
  -> exec { $ldap_setting:
    cwd      => '/var/tmp/',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    loglevel => debug,
    onlyif   => ["test ! -f  ${keytab_path_settings}/settings.py"],
    notify   => Service["${ldap_user}.service"],
  }

  #  Ensure ldap-passwd-reset service is running
  service { "${ldap_user}.service":
    ensure  => 'running',
    require => File["/etc/systemd/system/${ldap_user}.service"],
  }

  #  Create ldap-passwd-reset service
  file { "/etc/systemd/system/${ldap_user}.service":
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => $ldap_service,
    require => File[$keytab_path],
  }
  #  Create Keytab
  file { "${keytab_path}/${ldap_user}.keytab":
    ensure  => file,
    content => base64('decode', $keytab_base64),
    mode    => '0600',
    owner   => $ldap_user,
    group   => $ldap_user,
    require => File[$keytab_path],
  }
}

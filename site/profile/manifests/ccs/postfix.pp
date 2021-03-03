class profile::ccs::postfix(
  String        $auth,
  Array[String] $packages,
) {
  include postfix

  postfix::hash { '/etc/postfix/sasl_passwd':
    ensure  => 'present',
    content => $auth,
  }
  exec { 'sed -i \'/^::1/d\' /etc/hosts':
    cwd      => '/tmp',
    path     => ['/sbin', '/usr/sbin', '/bin'],
    provider => shell,
    onlyif   => 'grep \'::1         localhost\' /etc/hosts',
  }

  ensure_packages($packages)
  Package[$packages] -> Class[postfix]
}

class profile::ccs::postfix (
  String        $auth,
  Array[String] $packages,
) {
  include postfix

  postfix::hash { '/etc/postfix/sasl_passwd':
    ensure  => 'present',
    content => $auth,
  }

  ensure_packages($packages)
  Package[$packages] -> Class[postfix]
}

class profile::comcam::postfix(
  String $auth,
) {
  include postfix

  postfix::hash { '/etc/postfix/sasl_passwd':
    ensure  => 'present',
    content => $auth,
  }
}

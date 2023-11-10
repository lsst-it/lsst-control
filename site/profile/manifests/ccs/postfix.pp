# @summaryh
#   Configure postfix for authenticated relay.
#
# @param auth
#   Postfix host auth string/secret
#
# @param packages
#   List of postfix packages to install
#
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
  Package[$packages] -> Class['postfix']
}

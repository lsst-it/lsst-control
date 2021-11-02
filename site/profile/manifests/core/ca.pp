# @summary
#   Ensure that the ca-certificates packages is up to date because expired root certs are bad,
#   mkay?
#
#   See: https://letsencrypt.org/2019/04/15/transitioning-to-isrg-root.html
#
class profile::core::ca {
  ensure_resource('package', 'ca-certificates', {
      'ensure' => 'latest',
  })
}

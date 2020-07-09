# @summary
#   Ensure icingaweb2.conf file

class profile::core::icingaweb2conf
{
  include '::apache'
  include '::apache::mod::proxy'
  include '::apache::mod::proxy_fcgi'
  include '::apache::mod::ssl'

  ::apache::namevirtualhost { '*:443': }
  ::apache::listen { '443': }

  file { '/etc/httpd/conf.d/icingaweb2.conf':
    ensure => file,
    source => 'puppet:///modules/icingaweb2/examples/apache2/for-mod_proxy_fcgi.conf',
    notify => Service['httpd'],
  }
}

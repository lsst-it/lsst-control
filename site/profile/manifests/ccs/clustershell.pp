## @summary
##   Install clustershell and the appropriate local cfg file.
##
## @param config
##   String (default SITE-local.cfg) naming the cfg file to install.

class profile::ccs::clustershell (String $config = '') {

  ensure_packages(['clustershell'])

  $ptitle = regsubst($title, '::', '/', 'G')

  $dest = '/etc/clustershell/groups.d/local.cfg'
  $src = empty($config) ? {
    true    => "${::site}-local.cfg",
    default => $config,
  }

  file { $dest:
      ensure => present,
      source => "puppet:///modules/${ptitle}/${src}",
    }

}

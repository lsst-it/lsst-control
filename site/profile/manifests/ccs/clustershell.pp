## @summary
##   Install clustershell and the appropriate local cfg file.
##
## @param config
##   String (default SITE-local.cfg) naming the cfg file to install.

class profile::ccs::clustershell (String $config = '') {

  ensure_packages(['clustershell'])

  $dest = '/etc/clustershell/groups.d/local.cfg'
  $src = empty($config) ? {
    true    => "${facts['site']}-local.cfg",
    default => $config,
  }

  file { $dest:
    ensure => present,
    source => "puppet:///modules/${module_name}/ccs/clustershell/${src}",
  }

}

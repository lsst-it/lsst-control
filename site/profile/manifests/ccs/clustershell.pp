class profile::ccs::clustershell {

  ensure_packages(['clustershell'])

  $ptitle = regsubst($title, '::', '/', 'G')

  $file = '/etc/clustershell/groups.d/local.cfg'
  $src = "${facts['site']}-local.cfg"

  file { $file:
      ensure => present,
      source => "puppet:///modules/${ptitle}/${src}",
    }

}

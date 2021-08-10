class profile::ccs::profile_d {
  ## Environment variables etc.
  ## https://lsstc.slack.com/archives/CCQBHNS0K/p1553877151009500
  $file = 'lsst-ccs.sh'

  file { "/etc/profile.d/${file}":
    ensure => present,
    source => "puppet:///modules/${module_name}/ccs/profile_d/${file}",
  }
}

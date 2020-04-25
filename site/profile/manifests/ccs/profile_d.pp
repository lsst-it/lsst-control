class profile::ccs::profile_d {

  $ptitle = regsubst($title, '::', '/', 'G')

  ## Environment variables etc.
  ## https://lsstc.slack.com/archives/CCQBHNS0K/p1553877151009500
  $file = 'lsst-ccs.sh'

  file { "/etc/profile.d/${file}":
    ensure => present,
    source => "puppet:///modules/${ptitle}/${file}",
  }

}

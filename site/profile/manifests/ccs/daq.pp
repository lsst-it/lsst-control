## @summary
##   Add settings for DAQ network interfaces.

class profile::ccs::daq {

  $ptitle = regsubst($title, '::', '/', 'G')

  ## Note: asked not to modify DAQ network interfaces.
  $interface = "DISABLED-${profile::ccs::facts::daq_interface}"

  $file = '30-ethtool'

  file { "/etc/NetworkManager/dispatcher.d/${file}":
    ensure  => file,
    content => epp("${ptitle}/${file}", {'interface' => $interface}),
    mode    => '0755',
  }

}

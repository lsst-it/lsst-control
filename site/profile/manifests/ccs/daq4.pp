## @summary
##   Settings for DAQv4.

class profile::ccs::daq4 ($instrument = 'comcam') {

  $dir = '/etc/ccs'

  $attributes = {
    'owner' => 'ccsadm',
    'group' => 'ccsadm',
    'mode'  => '0644',
  }

  $daq4file = 'daqv4-setup'

  file { "${dir}/${daq4file}":
    ensure  => file,
    content => @(EOF),
      export DAQ_HOME=/srv/nfs/lsst-daq/daq-sdk/current/
      export LD_LIBRARY_PATH=$DAQ_HOME/x86/lib:$LD_LIBRARY_PATH
      | EOF
    *       => $attributes,
  }

  file { ["${dir}/store.app", "${dir}/${instrument}-ih.app"]:
    ensure  => file,
    content => "system.pre-execute=${daq4file}\n",
    *       => $attributes,
  }

}

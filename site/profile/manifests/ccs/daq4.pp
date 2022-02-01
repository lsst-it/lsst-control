# @summary
#   Settings for DAQv4.
#
# @param instrument
#   Instrument (camera) name.
#
class profile::ccs::daq4 (String $instrument = 'comcam') {
  $dir = '/etc/ccs'

  $attributes = {
    'owner' => 'ccsadm',
    'group' => 'ccsadm',
    'mode'  => '0644',
  }

  $daq4file = 'daqv4-setup'

  file { "${dir}/${daq4file}":
    ensure  => file,
    # lint:ignore:strict_indent
    content => @(EOF),
      export DAQ_HOME=/srv/nfs/lsst-daq/daq-sdk/current/
      export LD_LIBRARY_PATH=$DAQ_HOME/x86/lib:$LD_LIBRARY_PATH
      | EOF
    # lint:endignore
    *       => $attributes,
  }

  file { ["${dir}/store.app", "${dir}/${instrument}-ih.app"]:
    ensure  => file,
    content => "system.pre-execute=${daq4file}\n",
    *       => $attributes,
  }
}

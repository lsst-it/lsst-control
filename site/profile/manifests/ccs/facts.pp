## @summary
##   Define some variables
##
## @param daq
##   String naming the DAQ network interface; or true to detect it; or
##   false if none.

class profile::ccs::facts (Variant[Boolean,String] $daq = false) {

  ## Interfaces matching given ip pattern.
  $ifaces = $facts['networking']['interfaces'].filter |$eth, $hash| {
    $hash['ip'] and ($hash['ip'] =~ /^(134|140|139)/)
  }
  ## First match.
  $iface = $ifaces.keys()[0]
  ## Global.
  $main_interface = pick($iface, 'eth0')


  ## It makes life much easier if instead of doing this we ensure the
  ## interface is 'lsst-daq'.  TODO this section to be removed.
  if $daq {

    ## Normally the interface is "lsst-daq", but not always (eg lsst-dc02).
    ## TODO discover it?
    ## Could check for an interface connected to 192.168.100.1?
    $idefault = 'p3p1'
    $imaybe = 'lsst-daq'

    ## lsst-daq if exists, else p3p1.
    $interface0 = $facts['networking']['interfaces'][$imaybe] ? {
      undef   => $idefault,
      default => $imaybe,
    }

    ## Global.
    $daq_interface = $daq ? {
      String  => $daq,
      default => $interface0 ,
    }
  }


}

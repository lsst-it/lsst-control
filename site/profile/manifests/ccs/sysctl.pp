class profile::ccs::sysctl {
  $file = '/etc/sysctl.d/99-lsst-daq-ccs.conf'

  sysctl::value {
    default:
      target => $file,
      ;
    'net.core.wmem_max':
      value => 18874368,
      ;
    'net.core.rmem_max':
      value => 18874368,
      ;
  }
}

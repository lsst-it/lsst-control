class profile::comcam::cc_daq {
  include cron
  include r10k
  include r10k::webhook
  include r10k::webhook::config
  include scl

  Class['r10k::webhook::config'] -> Class['r10k::webhook']
}

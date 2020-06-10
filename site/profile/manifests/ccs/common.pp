#
# @summary
#   Common functionality needed by ccs nodes.
#
class profile::ccs::common {
  include profile::ccs::facts
  include profile::ccs::home
  include profile::ccs::users
  include profile::ccs::clustershell
  include profile::ccs::profile_d
  include profile::ccs::sudo
  include profile::ccs::monitoring
  include profile::ccs::sysctl

  include ccs_software
  include java_artisanal

  Class['java_artisanal']
  -> Class['ccs_software']
}

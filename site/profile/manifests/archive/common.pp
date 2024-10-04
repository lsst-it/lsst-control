# @summary
#   Common archiver functionality.
#
class profile::archive::common {
  include profile::archive::data
  include profile::core::common
  include profile::core::debugutils
  include profile::core::nfsclient
  include profile::core::nfsserver
}

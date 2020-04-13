# @summary
#   Provide remote desktop services for GUI applications.
class profile::core::remote_desktop {
  include mate
  class { 'x2go':
    client => false,
    server => true,
  }
}

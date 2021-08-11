# @summary
#   Install Dell perccli util
#
class profile::core::perccli {
  require profile::core::yum::dell

  ensure_packages(['perccli'])
}

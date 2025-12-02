# @summary
#   Install Dell perccli util
#
class profile::core::perccli {
  require profile::core::yum::dell

  stdlib::ensure_packages(['perccli'])
}

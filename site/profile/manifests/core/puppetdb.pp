# @summary
#   Install puppetdb
#
class profile::core::puppetdb {
  include scl
  include puppetdb

  Class['scl'] -> Class['puppetdb']
}

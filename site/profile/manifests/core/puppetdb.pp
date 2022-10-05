# @summary
#   Install puppetdb
#
class profile::core::puppetdb {
  include puppetdb

  if fact('os.family') == 'RedHat' and fact('os.release.major') == '7' {
    include scl
    Class['scl'] -> Class['puppetdb']
  }
}

# @summary
#  Manage centos yum-cron
#
class profile::core::yum::cron {
  package { 'yum-cron':
    ensure => absent,
  }
}

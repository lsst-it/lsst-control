# @summary
#   Define and integrate opsgenie to icinga2

class profile::icinga::opsgenie (
  String $credentials_hash,
){
  package { 'opsgenie-icinga2':
    ensure => 'present',
    source => 'https://s3-us-west-2.amazonaws.com/opsgeniedownloads/repo/opsgenie-icinga2-2.17.0-1.all.noarch.rpm',
  }
}

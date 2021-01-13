# @summary
#   Generic archiver forwarder host profile
#
# @param keytab_base64
#   base64 encoded krb5 keytab for the iip user
#
class profile::archive::forwarder(
  String $keytab_base64,
) {
  $iip_uid    = 61003
  $iip_keytab = '/home/iip/.keytab'

  file { $iip_keytab:
    ensure  => file,
    owner   => 'iip',
    group   => 'iip',
    mode    => '0400',
    content => base64('decode', $keytab_base64),
  }

  cron { 'k5start_root':
    command => "/usr/bin/k5start -f ${iip_keytab} -U -o iip -k /tmp/krb5cc_${iip_uid} -H 60 > /dev/null 2>&1",
    user    => 'root',
    minute  => '*/1',
    require => File[$iip_keytab],
  }
}

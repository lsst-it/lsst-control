# @summary
#   Generic archiver forwarder host profile
#
class profile::archive::forwarder {
  $iip_uid = 61003

  cron { 'k5start_root':
    command => "/usr/bin/k5start -f /etc/krb5.keytab -U -o root -k /tmp/krb5cc_${iip_uid} > /dev/null 2>&1",
    user    => 'root',
    minute  => '*/1',
  }
}

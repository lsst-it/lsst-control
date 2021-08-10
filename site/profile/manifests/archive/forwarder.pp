# @summary
#   Generic archiver forwarder host profile
#
# @param keytab_base64
#   base64 encoded krb5 keytab for the iip user
#
class profile::archive::forwarder (
  String $keytab_base64,
) {
  profile::util::keytab { 'iip':
    uid           => 61003,
    keytab_base64 => $keytab_base64,
  }
}

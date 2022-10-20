# @summary
#   Requests and creates a kerberos token
#
# @param user
#   Defines de user that requests the token
#
# @param uid
#   User ID for the ownership
#
# @param keytab_base64
#   base64 encoded krb5 keytab for the iip user
#
class profile::ccs::krb5_token (
  String $user,
  Integer $uid,
  Sensitive[String[1]] $keytab_base64,
) {
  profile::util::keytab { $user:
    uid           => $uid,
    keytab_base64 => $keytab_base64,
  }
}

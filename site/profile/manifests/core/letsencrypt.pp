# @summary Support for dns auth letsencrypt certs
#
# @param certonly
#   Hash of `letsencrypt::certonly` defined types to create.
#   See: https://github.com/voxpupuli/puppet-letsencrypt/blob/master/manifests/certonly.pp
class profile::core::letsencrypt(
  Optional[Hash[String, Hash]] $certonly = undef
) {
  include letsencrypt

  if ($certonly) {
    ensure_resources('letsencrypt::certonly', $certonly)
  }
}

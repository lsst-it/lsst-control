# @summary Support for dns auth letsencrypt certs
#
# @example
#   class profile::core::perfsonar {
#     include profile::core::letsencrypt
#     include augeas  # needed by perfsonar
#
#     $fqdn    = $facts['fqdn']
#     $le_root = "/etc/letsencrypt/live/${fqdn}"
#
#     letsencrypt::certonly { $fqdn:
#       plugin      => 'dns-route53',
#       manage_cron => true,
#     } ->
#     class { '::perfsonar':
#       manage_apache      => true,
#       remove_root_prompt => true,
#       ssl_cert           => "${le_root}/cert.pem",
#       ssl_chain_file     => "${le_root}/fullchain.pem",
#       ssl_key            => "${le_root}/privkey.pem",
#     }
#  }
#
# @param certonly
#   Hash of `letsencrypt::certonly` defined types to create.
#   See: https://github.com/voxpupuli/puppet-letsencrypt/blob/master/manifests/certonly.pp
class profile::core::letsencrypt(
  Optional[Hash[String, Hash]] $certonly = undef
) {
  include ::letsencrypt
  include ::letsencrypt::plugin::dns_route53

  # XXX https://github.com/voxpupuli/puppet-letsencrypt/issues/230
  ensure_packages(['python2-futures.noarch'])

  if ($certonly) {
    ensure_resources('letsencrypt::certonly', $certonly)
  }

  # aws credentials required by dns_route53 plugin.
  File['/root/.aws/credentials'] -> Letsencrypt::Certonly<| |>
}

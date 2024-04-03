# @summary
#   Install puppetboard https://github.com/voxpupuli/puppetboard
#
# @param secret_key
#  The secret key to use for the puppetboard
#
class profile::core::puppetboard (
  Sensitive[String[1]] $secret_key,
) {
  docker::image { 'ghcr.io/voxpupuli/puppetboard': }

  docker::run { 'puppetboard':
    image   => 'ghcr.io/voxpupuli/puppetboard',
    volumes => ['/etc/puppetlabs/puppet/ssl:/etc/puppetlabs/puppet/ssl:ro'],
    net     => 'host',
    env     => [
      'PUPPETDB_HOST=127.0.0.1',
      'PUPPETDB_PORT=8081',
      'PUPPETBOARD_PORT=8088',
      'ENABLE_CATALOG=true',
      'PUPPETDB_SSL_VERIFY=false',
      "PUPPETDB_KEY=/etc/puppetlabs/puppet/ssl/private_keys/${fact('networking.fqdn')}.pem",
      "PUPPETDB_CERT=/etc/puppetlabs/puppet/ssl/certs/${fact('networking.fqdn')}.pem",
      "SECRET_KEY=${secret_key.unwrap}",
      'DEFAULT_ENVIRONMENT=*',
    ],
  }
}

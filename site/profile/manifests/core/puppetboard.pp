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
    image => 'ghcr.io/voxpupuli/puppetboard',
    env   => [
      'PUPPETDB_HOST=127.0.0.1',
      'PUPPETDB_PORT=8080',
      'PUPPETBOARD_PORT=8088',
      "SECRET_KEY=${secret_key.unwrap}",
    ],
    net   => 'host',
  }
}

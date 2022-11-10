# @summary
#   Install `docker-compose` utility
#
class profile::core::docker::compose {
  ensure_packages(['docker-compose-plugin'])
}

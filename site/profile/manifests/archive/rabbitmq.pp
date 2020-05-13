class profile::archive::rabbitmq(
  Hash[String, Hash] $users = {},
  Hash[String, Hash] $vhosts = {},
){
  include ::rabbitmq

  # XXX hiera support should be upstreamed
  unless (empty($users)) {
    ensure_resources('rabbitmq_user', $users)
  }
  unless (empty($vhosts)) {
    ensure_resources('rabbitmq_vhost', $vhosts)
  }
}

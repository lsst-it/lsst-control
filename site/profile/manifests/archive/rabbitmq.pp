class profile::archive::rabbitmq(
  Hash[String, Hash] $users = {},
){
  include ::rabbitmq

  # XXX hiera support should be upstreamed
  unless (empty($users)) {
    ensure_resources('rabbitmq_user', $users)
  }
}

class profile::archive::rabbitmq(
  Hash[String, Hash] $users            = {},
  Hash[String, Hash] $vhosts           = {},
  Hash[String, Hash] $exchanges        = {},
  Hash[String, Hash] $queues           = {},
  Hash[String, Hash] $bindings         = {},
  Hash[String, Hash] $user_permissions = {},
){
  include ::rabbitmq

  # XXX hiera support should be upstreamed
  unless (empty($users)) {
    ensure_resources('rabbitmq_user', $users)
  }
  unless (empty($vhosts)) {
    ensure_resources('rabbitmq_vhost', $vhosts)
  }
  unless (empty($exchanges)) {
    ensure_resources('rabbitmq_exchange', $exchanges)
  }
  unless (empty($queues)) {
    ensure_resources('rabbitmq_queue', $queues)
  }
  unless (empty($bindings)) {
    ensure_resources('rabbitmq_binding', $bindings)
  }
  unless (empty($user_permissions)) {
    ensure_resources('rabbitmq_user_permissions', $user_permissions)
  }
}

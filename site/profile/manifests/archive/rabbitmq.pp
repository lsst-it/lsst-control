# @summary
#   Configure rabbitmq for archiver user
#
# @param users
#   `rabbitmq_user` resources to create.
#
# @param vhosts
#   `rabbitmq_vhost` resources to create.
#
# @param exchanges
#   `rabbitmq_exchange` resources to create.
#
# @param queues
#   `rabbitmq_queues` resources to create.
#
# @param bindings
#   `rabbitmq_binding` resources to create.
#
# @param user_permissions
#   `rabbitmq_user_permissions` resources to create.
#
# @param arc_queues
#   List of message queue/bindings to create.
#
# @param queue_user
#   Name of message queue user.
#
# @param queue_password
#   Message queue user password.
#
class profile::archive::rabbitmq (
  Hash[String, Hash] $users               = {},
  Hash[String, Hash] $vhosts              = {},
  Hash[String, Hash] $exchanges           = {},
  Hash[String, Hash] $queues              = {},
  Hash[String, Hash] $bindings            = {},
  Hash[String, Hash] $user_permissions    = {},
  Hash[String, Array[String]] $arc_queues = {},
  Optional[String] $queue_user            = undef,
  Optional[String] $queue_password        = undef,
) {
  class { 'rabbitmq':
    admin_enable      => true,
    management_enable => true,
    manage_python     => false,
    repos_ensure      => true,
    package_ensure    => '3.8.3-1.el7.noarch',
  }

  yum::install { 'erlang':
    ensure => present,
    source => 'https://github.com/rabbitmq/erlang-rpm/releases/download/v22.3.4/erlang-22.3.4-1.el7.x86_64.rpm',
    notify => Class['rabbitmq'],
  }

  yum::versionlock { ['0:rabbitmq-server-3.8.3-1.el7.noarch', '0:erlang-22.3.4-1.el7.x86_64']:
    ensure => 'present',
  }

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

  unless (empty($arc_queues)) {
    $arc_queues.each |String $vhost, Array $queues| {
      $queues.each |String $q| {
        rabbitmq_queue { "${q}@${vhost}":
          ensure   => present,
          user     => $queue_user,
          password => $queue_password,
          durable  => true,
        }
        rabbitmq_binding { "message@${q}@${vhost}":
          ensure           => present,
          user             => $queue_user,
          password         => $queue_password,
          destination_type => 'queue',
          routing_key      => $q,
        }
      } # $queues
    } # $arc_queues
  }
}

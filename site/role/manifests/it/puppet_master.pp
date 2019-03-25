# Role assigned to the puppet master deployment
class role::it::puppet_master{
  include profile::default
  include profile::it::puppet_master
}

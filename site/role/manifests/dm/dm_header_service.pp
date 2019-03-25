# Header service role
class role::dm::dm_header_service{
  include profile::default
  include profile::it::ssh_server
  include profile::dm::dm_header_service
}

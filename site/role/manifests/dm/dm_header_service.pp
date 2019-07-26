# Header service role
class role::dm::dm_header_service{
  include profile::default
  include ssh
  include profile::dm::dm_header_service
}

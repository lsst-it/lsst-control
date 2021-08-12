# @summary
#   Manage NFS mounts related to running CSCs
#
# @param mounts
#   Hash of nfs::client::mount resources to create
#
class profile::nfs::client::csc (
  Optional[Hash[String, Hash]] $mounts = undef,
) {
  if $mounts {
    include nfs
    include nfs::client
    ensure_resources('nfs::client::mount', $mounts)
  }
}

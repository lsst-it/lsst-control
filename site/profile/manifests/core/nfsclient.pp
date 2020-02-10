class profile::core::nfsclient {
  include nfs

  $nfs_mounts = hiera_hash('nfs::client_mounts', false)
  if $nfs_mounts {
    create_resources('::nfs::client::mount', $nfs_mounts)
  }
}

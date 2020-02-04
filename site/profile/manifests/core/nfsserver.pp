class profile::core::nfsserver {
  include nfs

  $nfs_exports_global = hiera_hash('nfs::nfs_exports_global', false)
  if $nfs_exports_global {
    create_resources('::nfs::server::export', $nfs_exports_global)
  }
}

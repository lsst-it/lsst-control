# @summary
#   Enable NFS V2
#
class profile::nfs::v2 {
  augeas { 'RPCNFSDARGS="-V 2"':
    context => '/files/etc/sysconfig/nfs',
    changes => 'set RPCNFSDARGS \'"-V 2"\'',
  }
}

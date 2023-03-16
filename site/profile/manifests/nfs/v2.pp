# @summary
#   Enable NFS V2
#
class profile::nfs::v2 {
  if fact('os.family') == 'RedHat' {
    if fact('os.release.major') == '7' {
      augeas { 'enable nfs v2 exports':
        context => '/files/etc/sysconfig/nfs',
        changes => 'set RPCNFSDARGS \'"-V 2"\'',
      }
    } else {
      # EL8/9 no longer support /etc/sysconfig/nfs
      augeas { 'enable nfs v2 exports':
        context => '/files/etc/nfs.conf/nfsd',
        lens    => 'Puppet.lns',
        incl    => '/etc/nfs.conf',
        changes => [
          'set vers2 yes',
          'set UDP yes',
        ],
      }
    }
  }
}

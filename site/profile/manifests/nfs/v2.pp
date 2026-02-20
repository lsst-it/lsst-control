# @summary
#   Enable NFS V2
#
class profile::nfs::v2 {
  if fact('os.family') == 'RedHat' {
    # EL8+ no longer supports /etc/sysconfig/nfs
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

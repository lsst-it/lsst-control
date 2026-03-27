# @summary
#  This class installs the gphoto2 package

class profile::pi::gphoto2 {
  yumrepo { 'gphoto2':
    descr               => 'Copr repo for gphoto2 owned by mareuter',
    baseurl             => 'https://download.copr.fedorainfracloud.org/results/mareuter/gphoto2/rhel-9-$basearch/',
    skip_if_unavailable => 'true',
    gpgcheck            => '1',
    gpgkey              => 'https://download.copr.fedorainfracloud.org/results/mareuter/gphoto2/pubkey.gpg',
    enabled             => '1',
    target              => '/etc/yum.repo.d/gphoto2.repo',
  }
  -> package { 'gphoto2':
    ensure => 'installed',
  }

  file { '/usr/bin/gphoto2':
    ensure => 'file',
    mode   => '0755',
  }
}

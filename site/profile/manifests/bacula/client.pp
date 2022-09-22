# @summary
#   Installs Bacula File Daemon in clients
#
# @param id
#   Bacula customer Identification string
#

class profile::bacula::client (
  String $id = 'null',
) {
  include yum

  $bacula_version = '14.0.4'

  #  Import Licenced GPG Bacula Key
  file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-BACULA':
    ensure => file,
    source => "https://www.baculasystems.com/dl/${id}/BaculaSystems-Public-Signature-08-2017.asc",
  }

  #  Bacula Enterprise Repository
  yumrepo { 'bacula':
    ensure   => 'present',
    baseurl  => "https://www.baculasystems.com/dl/${id}/rpms/bin/${bacula_version}/rhel7-64/",
    descr    => 'Bacula Enterprise Repository',
    enabled  => true,
    gpgcheck => '1',
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-BACULA',
    require  => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-BACULA'],
  }

  #  Fetch BIM - Bacula Installation Manager
  archive { '/opt/bee_installation_manager':
    ensure => present,
    source => 'https://www.baculasystems.com/ml/bee_installation_manager',
  }
}

# @summary
#   Installs Bacula File Daemon in clients
#
# @param id
#   Bacula customer Identification string
#

class profile::bacula::client (
  String $id = 'null',
  String $version = 'null',
) {
  include yum

  $bacula_packages = [
    "bacula-enterprise-libs-${version}-22060319.el7.x86_64",
    "bacula-enterprise-client-${version}-22060319.el7.x86_64",
  ]

  #  Import Licenced GPG Bacula Key
  file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-BACULA':
    ensure => file,
    source => "https://www.baculasystems.com/dl/${id}/BaculaSystems-Public-Signature-08-2017.asc",
  }

  #  Bacula Enterprise Repository
  yumrepo { 'bacula':
    ensure   => 'present',
    baseurl  => "https://www.baculasystems.com/dl/${id}/rpms/bin/${version}/rhel7-64/",
    descr    => 'Bacula Enterprise Repository',
    enabled  => true,
    gpgcheck => '1',
    gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-BACULA',
    require  => File['/etc/pki/rpm-gpg/RPM-GPG-KEY-BACULA'],
  }

  package { $bacula_packages:
    ensure => 'present',
  }
}

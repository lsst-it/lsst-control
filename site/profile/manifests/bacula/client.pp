# @summary
#   Installs Bacula File Daemon in clients
#
# @param id
#   Bacula customer Identification string
#
# @param version
#   Bacula's FD Version'
#
# @param bacula_dir
#   Bacula Director
#
# @param bacula_pwd
#   Bacula Enrollment Pasword
#

class profile::bacula::client (
  String $id = 'null',
  String $version = 'null',
  String $bacula_dir = 'null',
  String $bacula_pwd = 'null'
) {
  include yum

  $fqdn = $facts[fqdn]
  $bacula_root = '/opt/bacula'
  $bacula_fd_conf = @("BACULACONF")
    FileDaemon {
      Name = ${fqdn}-fd
      FDPort = 9102
      WorkingDirectory = "${bacula_root}/working"
      PIDDirectory = "${bacula_root}/working"
      PluginDirectory = "${bacula_root}/plugins"
      MaximumConcurrentJobs = 20
    }
    Director {
      Name = ${bacula_dir}-dir
      Password = "${bacula_pwd}"
    }
    Messages {
      Name = Default
      Director = ${fqdn}-dir = all, !skipped, !restored, !verified, !saved
    }

    |BACULACONF
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
  #  Fetch BIM - Bacula Installation Manager
  archive { '/opt/bee_installation_manager':
    ensure => present,
    source => 'https://www.baculasystems.com/ml/bee_installation_manager',
  }
  exec { "bash /opt/bee_installation_manager --director it-bacula-dir --download_area ${id} --version ${version} --silent":
    cwd    => '/var/tmp',
    path   => ['/sbin', '/usr/sbin', '/bin'],
    unless => "test -d ${bacula_root}",
  }
  #  Manage enrollment file
  -> file { "${bacula_root}/etc/bacula-fd.conf":
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0640',
    content => $bacula_fd_conf,
    notify  => Service['bacula-fd'],
  }
  -> service { 'bacula-fd':
    ensure => 'running',
    enable => true,
  }
}

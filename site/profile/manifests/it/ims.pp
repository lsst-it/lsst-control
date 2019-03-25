# This class configures the IMS in all the required servers
class profile::it::ims {
  package { 'sssd-common':
    ensure => installed
  }

  package{ 'sssd-ldap':
    ensure => installed
  }

  package{ 'sssd-krb5':
    ensure => installed
  }

  $ims_configuration = lookup('IMS_Configuration')

  ## SSSD Configuration

  file{'/etc/sssd/sssd.conf':
    ensure  => present,
    mode    => '0600',
    owner   => root,
    group   => root,
    require => Package['sssd-common']
  }

  file{ '/etc/pki/ca-trust/source/anchors/incommon-ca.pem':
    ensure => present,
    source => 'http://certmgr.techservices.illinois.edu/intermediate1.txt'
  }

  $sssd_config_array = $ims_configuration["SSSD"]

  $sssd_config_array.each | $section_name , $section_list| {
    $section_list.each | $property_hash| {
      $property_hash.each | $property_key, $property_value| {
        ini_setting { "Updating property ${property_key} = ${property_value} in SSSD configuration file":
          ensure  => present,
          path    => '/etc/sssd/sssd.conf',
          section => $section_name,
          setting => $property_key,
          value   => $property_value,
          require => File['/etc/sssd/sssd.conf']
        }
      }
    }
  }

  #TODO Define a condition to start SSSD, it must be after all the configurations are written

  service{ 'sssd' :
    ensure  => running,
    require => [Package['sssd-common'],Package['sssd-krb5']]
  }

  # Make sure home is created if doesn't exist

  file_line{ 'Adding mkhomedir support when Login' :
    path  => '/etc/pam.d/login',
    line  => 'session         required     pam_mkhomedir.so skel=/etc/skel/ umask=0022',
    match => '^session( )+required( )+pam_mkhomedir.so',
  }

  file_line{ 'Adding mkhomedir support when using su':
    path  => '/etc/pam.d/su',
    line  => 'session         required     pam_mkhomedir.so skel=/etc/skel/ umask=0022',
    match => '^session( )+required( )+pam_mkhomedir.so',
  }
}

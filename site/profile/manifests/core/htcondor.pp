# @summary
#   Installs htcondor as scheduler
#
# @param htcondor_version
#   check https://research.cs.wisc.edu/htcondor/repo/ for more versions
#
# @param htcondor_host
#   sets the central-manager host
#
# @param htcondor_pswfile
#   sets the location of the file
#
# @param htcondor_password
#   sets the access password
#
class profile::core::htcondor (

  String[1] $htcondor_version,
  String[1] $htcondor_host,
  Optional[String[1]] $htcondor_pswfile = undef,
  Optional[String[1]] $htcondor_password = undef,

) {
  yumrepo { 'condor':
    descr               => 'htcondor repo',
    baseurl             => "https://research.cs.wisc.edu/htcondor/repo/${htcondor_version}/el9/\$basearch/release/",
    skip_if_unavailable => 'true',
    gpgcheck            => '1',
    gpgkey              => "https://research.cs.wisc.edu/htcondor/repo/keys/HTCondor-${htcondor_version}-Key",
    enabled             => '1',
    target              => '/etc/yum.repos.d/htcondor.repo',
  }
  -> package { 'condor':
    ensure => 'installed',
  }

  file { '/etc/condor/condor_config.local':
    ensure  => file,
    content => @(EOF)
      ALLOW_WRITE = 10.*, 139.229.*
      ALLOW_NEGOTIATOR = 10.*, 139.229.*
      ALLOW_DAEMON = 10.*, 139.229.*
      
      use SECURITY: Strong
      SEC_DEFAULT_AUTHENTICATION_METHODS = FS, PASSWORD
      SEC_READ_AUTHENTICATION_METHODS = $(SEC_DEFAULT_AUTHENTICATION_METHODS),ANONYMOUS
      SEC_CLIENT_AUTHENTICATION_METHODS = $(SEC_DEFAULT_AUTHENTICATION_METHODS),ANONYMOUS
      
      DAEMON_LIST = $(DAEMON_LIST), SHARED_PORT
      SHARED_PORT_ARGS = -p 9618
      USE_SHARED_PORT = TRUE
      
      UPDATE_COLLECTOR_WITH_TCP = TRUE
      
      UID_DOMAIN = lsst.org
      FILESYSTEM_DOMAIN  = lsst.org
      SOFT_UID_DOMAIN = TRUE
      | EOF
    ,
    require => Yumrepo['condor'],
  }

  file { '/etc/condor/config.d/schedd':
    ensure  => file,
    content => 'DAEMON_LIST = MASTER, SCHEDD',
    require => Yumrepo['condor'],
  }

  if $htcondor_pswfile and $htcondor_password {
    file { regsubst($htcondor_pswfile, '^(.*/).*$', '\1'):
      ensure  => directory,
      require => Yumrepo['condor'],
    }

    file { $htcondor_pswfile:
      ensure  => file,
      mode    => '0600',
      content => $htcondor_password,
      require => Yumrepo['condor'],
    }

    file { '/etc/condor/config.d/docker':
      ensure  => file,
      content => @("EOF")
        CONDOR_HOST = ${htcondor_host}
        SEC_PASSWORD_FILE = ${htcondor_pswfile}
        | EOF
      ,
      require => Yumrepo['condor'],
    }
  }
  service { 'condor':
    ensure  => 'running',
    enable  => true,
    require => Yumrepo['condor'],
  }
}

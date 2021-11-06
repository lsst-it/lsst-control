## @summary
##   Installation of DAQ client:
##   Download DAQ tarfile, extract it, create /etc/ccs config files.

class profile::ccs::daq_client (
  String $prefix = '/opt/lsst/daq',
  String $repo = 'https://repo-nexus.lsst.org/nexus/repository/daq/daq-sdk',
  String $version = 'R5-V0.6',
  String $owner = 'ccsadm',
  String $group = 'ccsadm',
  String $config_dir = '/etc/ccs',
  String $instrument = 'comcam',
) {
  ensure_packages(['tar', 'gzip'])

  ensure_resources('file', {
      $prefix => {
        ensure => directory,
        mode   => '0775',
        owner  => $owner,
        group  => $group,
      },
  })

  $tarfile = "${version}.tgz"

  $daq_home = "${prefix}/${version}"

  ## todo: tarfile is owned by root:root.
  archive { "${prefix}/${tarfile}":
    ensure       => present,
    source       => "${repo}/${tarfile}",
    extract      => true,
    extract_path => $prefix,
    cleanup      => false,
    creates      => $daq_home,
    user         => $owner,
    group        => $group,
  }

  ## Point the "current" symlink to this version.
  file { "${prefix}/current":
    ensure => link,
    target => $version,
    owner  => $owner,
    group  => $group,
  }

  if $version =~ /R(\d+)/ {
    $daq_version = $1

    $daq_setup = "${config_dir}/daqv${daq_version}-setup"

    file { $daq_setup:
      ensure  => file,
      content => epp("${module_name}/ccs/daq_client/daqvX-setup.epp", { 'home' => $daq_home }),
      owner   => $owner,
      group   => $group,
      mode    => '0644',
    }

    ## TODO Is it -ih for v4 and -fp for v5?
    $appfiles = ['store.app', "${instrument}-ih.app", "${instrument}-fp.app"]

    $appfiles.each | $appfile | {
      file { "${config_dir}/${appfile}":
        ensure  => file,
        content => epp("${module_name}/ccs/daq_client/daq.app.epp", { 'setup_file' => "${basename($daq_setup)}" }),
        owner   => $owner,
        group   => $group,
        mode    => '0644',
      }
    }
  } else {
    fail("Could not figure out DAQ version from ${version}")
  }
}

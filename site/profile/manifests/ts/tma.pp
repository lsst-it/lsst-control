# @summary
# TMA multi-user workstation: XFCE, Docker services, LabVIEW, VIPM
#
# @param tma_db_repo TMA MariaDB repository
# @param tma_db_path Path for TMA DB (shared service)
# @param github_token GitHub Personal Access Token for private repos (optional)
# @param pxi_0_ip PXI 0 IP address
# @param pxi_1_ip PXI 1 IP address
# @param opman_path Operation Manager path (shared service)
# @param labview_rpm_url Full URL to NI LabVIEW RPM
# @param compose_cmd Docker compose command (docker-compose or docker compose)
# @param ghcr_username GitHub Container Registry username
# @param ghcr_token GitHub Container Registry token (Sensitive)
# @param vipm_url VIPM ZIP download URL
# @param vipc_url VIPC dependencies URL
# @param vipm_root VIPM root installation path
# @param vipc_path VIPC file destination path
# @param enable_graphical Enable graphical mode (XFCE + GDM)
# @param tma_group LDAP group name for TMA users (must exist in FreeIPA)
class profile::ts::tma (
  String[1]                      $tma_db_repo,
  Stdlib::Absolutepath           $tma_db_path,
  String[1]                      $pxi_0_ip,
  String[1]                      $pxi_1_ip,
  Optional[Sensitive[String[1]]] $github_token            = undef,
  Stdlib::Absolutepath           $opman_path              = '/opt/tma/operation-manager',
  String[1]                      $labview_rpm_url         = 'https://repo-nexus.lsst.org/nexus/repository/ts_yum/releases/ni-labview-2024-pro-24.3.2.49152-0%2Bf0-rhel9.noarch.rpm',
  String[1]                      $compose_cmd             = 'docker-compose',
  Optional[String[1]]            $ghcr_username           = undef,
  Optional[Sensitive[String[1]]] $ghcr_token              = undef,
  Optional[String[1]]            $vipm_url                = undef,
  String[1]                      $vipc_url                = 'https://github.com/lsst-ts/ts_tma_vipm_dependency/raw/develop/LSST_tma_dependencies.vipc',
  Stdlib::Absolutepath           $vipm_root               = '/usr/local/JKI/VIPM',
  Stdlib::Absolutepath           $vipc_path               = '/usr/local/JKI/VIPM/LSST_tma_dependencies.vipc',
  Boolean                        $enable_graphical        = true,
  String[1]                      $tma_group               = 'tma',
) {
  if $enable_graphical {
    ensure_packages(['@base-x', '@xfce-desktop'])

    exec { 'set-graphical-target':
      command => '/bin/systemctl set-default graphical.target',
      unless  => '/bin/systemctl get-default | grep -q graphical.target',
      onlyif  => '/bin/systemctl is-active sssd',
      path    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
      require => [Package['@base-x'], Package['@xfce-desktop']],
    }

    file { '/etc/gdm/custom.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('profile/ts/tma/gdm-custom.conf.epp'),
      notify  => Service['gdm'],
    }

    service { 'gdm':
      ensure  => running,
      enable  => true,
      require => [Exec['set-graphical-target'], Package['@xfce-desktop']],
    }
  }

  if $ghcr_username != undef and $ghcr_token != undef {
    exec { 'docker-login-ghcr':
      command => "bash -lc 'printf %s ${ghcr_token.unwrap} | docker login ghcr.io -u ${ghcr_username} --password-stdin'",
      unless  => "bash -lc 'docker info 2>/dev/null | grep -q ghcr.io'",
      path    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
    }
  }

  file { '/opt/tma':
    ensure => directory,
    owner  => 'root',
    group  => $tma_group,
    mode   => '0775',
  }

  if $github_token != undef {
    file { $tma_db_path:
      ensure  => directory,
      owner   => 'root',
      group   => $tma_group,
      mode    => '2775',
      require => File['/opt/tma'],
    }

    $tma_db_source = regsubst($tma_db_repo, '^git@github\.com:', "https://${github_token.unwrap}@github.com/")

    vcsrepo { $tma_db_path:
      ensure   => present,
      provider => git,
      source   => $tma_db_source,
      require  => File[$tma_db_path],
    }

    file { "${tma_db_path}/backup":
      ensure => directory,
      owner  => 'root',
      group  => $tma_group,
      mode   => '2775',
    }

    exec { 'tma-db-up':
      command     => "${compose_cmd} up -d",
      cwd         => $tma_db_path,
      refreshonly => true,
      subscribe   => Vcsrepo[$tma_db_path],
      path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin', '/usr/local/bin'],
    }

    cron { 'tma-db-createbackup':
      ensure  => present,
      command => "${tma_db_path}/createbackup.pl",
      minute  => '5',
      hour    => '12',
      user    => 'root',
    }

    cron { 'tma-db-python-backup':
      ensure  => present,
      command => "docker run --rm -v ${tma_db_path}/python:/script -v ${tma_db_path}/backup:/backup python:3.7 python /script/main.py",
      minute  => '5',
      hour    => '13',
      user    => 'root',
    }
  } else {
    notify { 'tma-db-skip':
      message => 'TMA DB skip: no GitHub token',
    }
  }

  file { $opman_path:
    ensure  => directory,
    owner   => 'root',
    group   => $tma_group,
    mode    => '2775',
    require => File['/opt/tma'],
  }

  $compose_content = @("COMPOSE")
    version: '3'
    services:
      mt-mount-manager:
        image: ghcr.io/lsst-ts/ts_tma_operation-manager_mt-mount-operation-manager:latest
        container_name: mt-mount-manager
        ports:
          - "60005:60005"
          - "40005:40005"
          - "30005:30005"
        volumes:
          - /var/log/mtmount_operation_manager/:/var/log/mtmount_operation_manager
        environment:
          - PXI_0_IP=${pxi_0_ip}
          - PXI_1_IP=${pxi_1_ip}
        restart: unless-stopped
    | COMPOSE

  file { "${opman_path}/docker-compose.yml":
    ensure  => file,
    owner   => 'root',
    group   => $tma_group,
    mode    => '0664',
    content => $compose_content,
    notify  => Exec['opman-up'],
  }

  exec { 'opman-up':
    command     => "${compose_cmd} up -d",
    cwd         => $opman_path,
    refreshonly => true,
    path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin', '/usr/local/bin'],
  }

  yumrepo { 'ni-labview-2024-el9-pro':
    ensure        => present,
    baseurl       => 'https://download.ni.com/ni-linux-desktop/LabVIEW/2024/Q3/f2/pro/rpm/ni-labview-2024/el9',
    enabled       => 1,
    gpgcheck      => 0,
    repo_gpgcheck => 0,
    before        => Package['ni-labview-2024-pro'],
  }

  package { 'ni-labview-2024-pro':
    ensure => '24.3.2.49152-0+f0',
  }

  file { ['/usr/local/JKI', '/etc/JKI']:
    ensure => directory,
    owner  => 0,
    group  => 0,
    mode   => '0755',
  }

  file { $vipm_root:
    ensure  => directory,
    owner   => 0,
    group   => 0,
    mode    => '0755',
    require => File['/usr/local/JKI'],
  }

  if $vipm_url != undef {
    exec { 'vipm-download':
      command => "curl -fsSL -o /tmp/vipm.zip ${vipm_url}",
      unless  => "test -x ${vipm_root}/vipm",
      path    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
      require => File[$vipm_root],
    }

    exec { 'vipm-unzip':
      command => "unzip -o /tmp/vipm.zip -d ${vipm_root} && rm -f /tmp/vipm.zip",
      unless  => "test -x ${vipm_root}/vipm",
      path    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
      require => Exec['vipm-download'],
    }
  }

  if $github_token != undef {
    exec { 'vipc-fetch':
      command => "bash -lc 'curl -fsSL -H \"Authorization: token ${github_token.unwrap}\" -o ${vipc_path} ${vipc_url}'",
      creates => $vipc_path,
      path    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
      require => File[$vipm_root],
    }
  } else {
    notify { 'vipc-skip':
      message => 'VIPC skip: no GitHub token',
    }
  }
}

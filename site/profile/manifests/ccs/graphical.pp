# @summary
#   Settings for hosts that should run in graphical mode.
#
# @param install
#   Boolean, false means do nothing.
# @param officeapps
#   Boolean, true means install libreoffice etc.
#
class profile::ccs::graphical (
  Boolean $install = true,
  Boolean $officeapps = false,
) {
  if $install {
    include profile::core::x2go

    ensure_packages(['gdm'])

    service { 'gdm':
      enable => true,
    }

    exec { 'Set graphical target':
      path    => ['/usr/sbin', '/usr/bin'],
      command => 'systemctl set-default graphical.target',
      unless  => 'sh -c "systemctl get-default | grep -qF graphical.target"',
    }

    $unwanted_gnome_pkgs = [
      'gnome-initial-setup',
      'libvirt-daemon',  # rm unused virbr0[-nic] interfaces
      'cockpit',
      'cockpit-bridge',
      'cockpit-storaged',
      'cockpit-ws',
      'cockpit-packagekit',
      'cockpit-podman',  # does not exist on el7
      'cockpit-system',
    ]

    ## Slow. Maybe better done separately?
    ## Don't want this on servers.
    ## Although people sometimes want to eg use vnc,
    ## so it does end up being needed on servers too.
    ## "Server with GUI" instead? Not much smaller.
    # Packages not present on EL8 or EL9
    if fact('os.release.major') == '7' {
      yum::group { 'GNOME Desktop':
        ensure  => present,
        timeout => 1800,
        notify  => Package[$unwanted_gnome_pkgs],
      }
      yum::group { 'MATE Desktop':
        ensure  => present,
        timeout => 900,
      }
    }
    else {
      yum::group { 'Server with GUI':
        ensure  => present,
        timeout => 900,
        notify  => Package[$unwanted_gnome_pkgs],
      }
      ensure_packages(['mate-desktop'])
    }

    package { $unwanted_gnome_pkgs:
      ensure => purged,
    }

    ensure_packages(['icewm'])
  }

  if $officeapps {
    ensure_packages(['libreoffice-base'])

    $zoomrpm = 'zoom.x86_64.rpm'
    $zoomfile = "/var/tmp/${zoomrpm}"

    archive { $zoomfile:
      ensure   => present,
      source   => "${profile::ccs::common::pkgurl}/${zoomrpm}",
      username => $profile::ccs::common::pkgurl_user.unwrap,
      password => $profile::ccs::common::pkgurl_pass.unwrap,
    }

    ## TODO use a local yum repository?
    package { 'zoom':
      ensure   => 'installed',
      provider => 'rpm',
      source   => $zoomfile,
    }
  }
}

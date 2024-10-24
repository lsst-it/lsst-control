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
      'NetworkManager-config-server',
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
      ## There doesn't seem to be a group for this in epel9.
      ensure_packages([
          'mate-desktop',
          'mate-applets',
          'mate-menu',
          'mate-panel',
          'mate-session-manager',
          'mate-terminal',
          'mate-themes',
          'mate-utils',
          'marco',
          'caja',
      ])
    }

    package { $unwanted_gnome_pkgs:
      ensure => purged,
    }

    ensure_packages(['icewm'])
  }

  if $officeapps {
    ensure_packages(['libreoffice-base'])

    if fact('os.release.major') == '9' {
      include 'google_chrome'
    }
  }
}

# @summary
#   Installs and sets Xfce
#
# @param wayland
#   Use wayland, false by default.
#
# @param graphical
#   sets systemd for graphical or text login.
#
class profile::util::xfce (
  Boolean $wayland = false,
  Boolean $graphical = true,
) {
  include yum

  yum::group { 'Xfce':
    ensure  => present,
    timeout => 600,
  }

  if $wayland == false {
    file_line { 'disable_wayland':
      path  => '/etc/gdm/custom.conf',
      match => '^#?WaylandEnable=',
      line  => 'WaylandEnable=false',
    }
  } else {
    file_line { 'enable_wayland':
      path  => '/etc/gdm/custom.conf',
      match => '^#?WaylandEnable=',
      line  => 'WaylandEnable=true',
    }
  }

  if $graphical {
    $target = 'graphical.target'
  } else {
    $target = 'multi-user.target'
  }

  exec { "set_systemd_${target}":
    command => "systemctl set-default ${target}",
    unless  => "systemctl get-default | grep -q ${target}",
    path    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
  }
}

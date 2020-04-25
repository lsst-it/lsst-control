## @summary
##   Control automatic login for ccs graphical session.
##
## @param enable
##   Boolean saying whether to enable or disable autologin.

class profile::ccs::autologin (Boolean $enable = true) {

  if $enable {
    ensure_packages(['gdm'])

    exec { 'Enable autologin for graphical ccs user':
      path    => ['/usr/bin'],
      unless  => 'grep -q ^AutomaticLogin /etc/gdm/custom.conf',
      command => @("CMD"/L),
        sed -i '/^\[daemon.*/a\\
        AutomaticLogin=ccs\n\
        AutomaticLoginEnable=true' /etc/gdm/custom.conf
        | CMD
    }

  } else {

    exec { 'Disable autologin for graphical ccs user':
      path    => ['/usr/bin'],
      onlyif  => 'grep -q ^AutomaticLogin=ccs /etc/gdm/custom.conf',
      command => 'sed -i "/^AutomaticLogin/d" /etc/gdm/custom.conf',
    }

  }

}

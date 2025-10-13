# @summary
#   Control automatic login for ccs graphical session.
#
# @param enable
#   Boolean saying whether to enable or disable autologin.
#
class profile::ccs::autologin (Boolean $enable = true) {
  if $enable {
    ensure_packages(['gdm'])

    exec { 'Enable timedlogin for graphical ccs user':
      path    => ['/usr/bin'],
      unless  => 'grep -q ^TimedLogin /etc/gdm/custom.conf',
      # lint:ignore:strict_indent
      command => @("CMD"/L),
        sed -i '/^\[daemon.*/a\\
        TimedLogin=ccs\n\
        TimedLoginDelay=60\n\
        TimedLoginEnable=true' /etc/gdm/custom.conf
        | CMD
      # lint:endignore
    }
  } else {
    exec { 'Disable timedlogin for graphical ccs user':
      path    => ['/usr/bin'],
      onlyif  => 'grep -q ^TimedLogin=ccs /etc/gdm/custom.conf',
      command => 'sed -i "/^TimedLogin/d" /etc/gdm/custom.conf',
    }
  }
}

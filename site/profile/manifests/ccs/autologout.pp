# @summary
#   Enable automatic logout for gnome sessions.
#
class profile::ccs::autologout {
  $dconf_power = 'org/gnome/settings-daemon/plugins/power'
  $dconf_sleep = 'sleep-inactive-ac'

  ## Cannot lock -type, since need to change it for the ccs user.
  dconf::settings { 'gnome power inactive-ac':
    settings_hash => {
      $dconf_power => {
        "${dconf_sleep}-timeout" => { 'value' => 900, 'lock' => true },
        "${dconf_sleep}-type"    => { 'value' => "'logout'", 'lock' => false },
      },
    },
  }

  ## Set sleep-inactive-ac-type='nothing' for the CCS user.
  $ccs_user = 'ccs'

  exec { 'ccs dconf disable autologout':
    path    => ['/usr/bin/'],
    command => "dbus-launch dconf write /${dconf_sleep}-type \"'nothing'\"",
    user    => $ccs_user,
    unless  => "dconf read /${dconf_sleep}-type | grep -q nothing",
  }
}

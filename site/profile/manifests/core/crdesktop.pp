# @summary
#   Sets power display settings on control rooms desktops for CP and LS. 
#
class profile::core::crdesktop () {
  cron { 'disable_dpms':
  command => '/usr/bin/xset -dpms',
  user    => 'root',
  minute  => '*/2',
  }
}

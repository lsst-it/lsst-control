## @summary
##  Install a cron.hourly script that allows the ccs user to user
##  sudo to control ccs services.
##
## Maybe replace this with puppet?
## Would need a custom fact that finds the ccs services,
## which is a large part of what the ccs-sudoers-services script does.
## So probably not worth splitting out the part that writes the
## sudoers file.

class profile::ccs::sudo {

  $file = 'ccs-sudoers-services'

  file { "/etc/cron.hourly/${file}":
    ensure => present,
    source => "puppet:///modules/${module_name}/ccs/sudo/${file}",
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }

}

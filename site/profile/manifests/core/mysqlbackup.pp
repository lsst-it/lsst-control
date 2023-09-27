# @summary
#   mysqldump class
#
# @param packages
#  An array of packages to install
#
class profile::core::mysqlbackup (
  $mysql_user,
  $mysql_passwd,
  $databases,
  Optional[String] $mysqldump_extra_params,
  $hour,
  $minute,
  $weekday,
  Optional[String] $email
) {

  include mysqldump

  mysqldump::backup { 'daily':
    mysql_user             => $mysql_user,
    mysql_passwd           => $mysql_passwd,
    databases              => $databases,
    mysqldump_extra_params => $mysqldump_extra_params,
    hour                   => $hour,
    minute                 => $minute,
    weekday                => $weekday,
    email                  => $email,
  }
}

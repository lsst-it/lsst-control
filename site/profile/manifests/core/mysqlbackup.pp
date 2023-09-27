# @summary
#   mysqldump class
#
# @param databases
#   A string or an array containing the names of the database(s) to back up. 
#   Defaults the resource $title. Use 'all' to back up all databases.
#
# @param mysql_user
#   MySQL user with rights to dump the specified databases. Defaults to 'root'.
#
# @param mysql_passwd
#   Password for the above user.
#
# @param mysqldump_extra_params
#   Extra parameters to pass to mysqldump. Defaults to '--lock-tables', which 
#   works for MyISAM tables. For InnoDB tables '--single-transaction' is more 
#   appropriate.
#
# @param hour
#   Hour(s) when mysqldump gets run. String or Integer or an array of them.
#   Defaults to '01'.
#
# @param minute
#   Minute(s) when mysqldump gets run. Defaults to '10'.
*
# @param weekday
#   Weekday(s) when mysqldump gets run. Defaults to '*' (all weekdays).
#
# @param email
#   Email address where notifications are sent. Defaults to top-scope variable
#   $::servermonitor.
#
class profile::core::mysqlbackup (
  $mysql_user            = undef,
  $mysql_passwd          = undef,
  $databases             = [],
  $mysqldump_extra_params = undef,
  $hour                  = [],
  $minute                = [],
  $weekday               = [],
  $email                 = undef,
) {

  ::mysqldump::backup { 'daily':
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

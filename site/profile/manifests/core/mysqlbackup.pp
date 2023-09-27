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
  Optional[String] $mysql_user,
  Optional[String] $mysql_passwd,
  Variant[String, Array]  $databases,
  Optional[String] $mysqldump_extra_params,
  Variant[Array[String], Array[Integer[0-23]], String, Integer[0-23]] $hour,
  Variant[Array[String], Array[Integer[0-59]], String, Integer[0-59]] $minute,
  Variant[Array[String], Array[Integer[0-7]],  String, Integer[0-7]] $weekday,
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

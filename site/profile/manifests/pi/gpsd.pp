# @summary
#   Manage the gpsd service.
#
#   See: https://gpsd.gitlab.io/gpsd/index.html
#
#   Note that the package names on el9/aarch64 are different from el9/amd64.
#
# @param packages
#  An array of packages to install
#
# @param options
#  Value of the OPTIONS variable in /etc/sysconfig/gpsd
#
class profile::pi::gpsd (
  Optional[Array[String[1]]] $packages = undef,
  Optional[String[1]] $options = undef,
) {
  if $packages {
    ensure_packages($packages)
  }

  if $options {
    augeas { 'gpsd options':
      context => '/files/etc/sysconfig/gpsd',
      changes => "set OPTIONS \"\\\"${options}\\\"\"",
      require => Package[$packages],
    }
  }
}

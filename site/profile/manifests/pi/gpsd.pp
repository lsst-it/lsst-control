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
  systemd::dropin_file { 'gpsd.conf':
    unit    => 'gpsd.socket',
    # lint:ignore:strict_indent
    content => @(EOS),
      [Socket]
      ListenStream=/run/gpsd.sock
      #ListenStream=[::1]:2947
      ListenStream=127.0.0.1:2947
      # To allow gpsd remote access, start gpsd with the -G option and
      # uncomment the next two lines:
      # ListenStream=[::]:2947
      # ListenStream=0.0.0.0:2947
      SocketMode=0600
      BindIPv6Only=yes
      | EOS
    # lint:endignore
  }
}

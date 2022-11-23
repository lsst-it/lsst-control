# @summary
#  Create a .nmconnection file
#
# @param content
#   Verbatim content of .nmconnection "keyfile".
#   See: https://networkmanager.dev/docs/api/latest/nm-settings-keyfile.html
#
# @param ensure
#   If connection file should be present or absent.
#
define profile::nm::connection (
  String[1] $content,
  Enum['present', 'absent'] $ensure = 'present',
) {
  $_real_ensure = $ensure ? {
    'absent' => 'absent',
    default  => 'file',
  }

  file { "${profile::nm::conn_dir}/${name}.nmconnection":
    ensure  => $_real_ensure,
    mode    => '0600',
    content => $content,
    notify  => Exec['nmcli conn reload'],
  }
}

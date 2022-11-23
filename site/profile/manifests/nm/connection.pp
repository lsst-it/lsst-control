# @summary
#  Create a .nmconnection file
#
# @param content
#   Verbatim content of .nmconnection "keyfile".
#   See: https://networkmanager.dev/docs/api/latest/nm-settings-keyfile.html
#
define profile::nm::connection (
  String[1] $content,
) {
  file { "${profile::nm::conn_dir}/${name}.nmconnection":
    ensure  => file,
    mode    => '0600',
    content => $content,
    notify  => Exec['nmcli conn reload'],
  }
}

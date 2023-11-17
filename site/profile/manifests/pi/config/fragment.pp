# @summary
#  Create a /boot/config.txt fragment
#
# @param content
#   /boot/config.txt configuration fragment
#
# @param order
#   Order of the fragment within /boot/config.txt
#
define profile::pi::config::fragment (
  String[1] $content,
  Integer[1] $order = 50,
) {
  concat::fragment { $name:
    target  => '/boot/config.txt',
    content => $content,
    order   => $order,
  }

  if Class['profile::pi::config']['reboot'] {
    Concat::Fragment[$name] ~> Reboot['/boot/config.txt']
  }
}

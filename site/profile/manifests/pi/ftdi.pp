# @summary
#   Manages FTDI / Future Technology Devices International Ltd. USB serial
#   devices.
#
class profile::pi::ftdi {
  if defined(Class['profile::core::docker']) {
    $group = Class['profile::core::docker']['socket_group']
  } else {
    $group = '70014'
  }

  systemd::udev::rule { 'ftdi.rules':
    rules => [
      "SUBSYSTEMS==\"usb\", ATTRS{idVendor}==\"0403\", GROUP=\"${group}\", MODE=\"0660\"",
    ],
  }
}

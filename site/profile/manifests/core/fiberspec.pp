# @summary
#   Manages Avantes Fiberspectrometer USB devices.
#
class profile::core::fiberspec {
  systemd::udev::rule { 'fiberspec.rules':
    rules => [
      "SUBSYSTEM==\"usb\", ATTR{idVendor}==\"1992\", ATTR{idProduct}==\"0667\", ACTION==\"add\", GROUP=\"saluser\", MODE=\"0664\"",
    ],
  }
}

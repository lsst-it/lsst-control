# @summary
#   Darken PI status LEDs
#
class profile::pi::darkmode {
  pi::config::fragment { 'darkmode':
    # lint:ignore:strict_indent
    content => @("CONTENT"),
      [pi4]
      # Disable the PWR LED
      dtparam=pwr_led_trigger=default-on
      dtparam=pwr_led_activelow=off
      # Disable the Activity LED
      dtparam=act_led_trigger=none
      dtparam=act_led_activelow=off
      # Disable ethernet port LEDs
      dtparam=eth_led0=4
      dtparam=eth_led1=4
      | CONTENT
    # lint:endignore
  }
}

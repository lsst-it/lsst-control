# frozen_string_literal: true

shared_examples 'add_usb' do
  it do
    is_expected.to contain_systemd__udev__rule('add_usb.rules').with(
      rules: [
        'SUBSYSTEM=="tty", ACTION=="add", RUN+="/usr/local/bin/add_usb.sh \'$devnode\'"',
      ],
    )
  end

  it do
    is_expected.to contain_file('/usr/local/bin/add_usb.sh').with(
      ensure: 'file',
      mode: '0755',
      content: <<~CONTENT,
        #!/bin/bash
        tty_path=$1
        tty_device=$(basename "$tty_path")
        serial_port=$(ls -l /dev/serial/by-path | grep "$tty_device" | awk '{print $9}')

        usb_hard_link="undefined"
        case "$serial_port" in
            "platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.2:1.0-port0")
                usb_hard_link="/dev/ttyUSB_lower_right"
                ;;
            "platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.1:1.0-port0")
                usb_hard_link="/dev/ttyUSB_upper_right"
                ;;
            "platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.4:1.0-port0")
                usb_hard_link="/dev/ttyUSB_lower_left"
                ;;
            "platform-fd500000.pcie-pci-0000:01:00.0-usb-0:1.3:1.0-port0")
                usb_hard_link="/dev/ttyUSB_upper_left"
                ;;
        esac

        if [ -e "$usb_hard_link" ]; then
            rm "$usb_hard_link"
        fi

        ln "$tty_path" "$usb_hard_link"
      CONTENT
    )
  end
end

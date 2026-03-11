# frozen_string_literal: true

shared_examples 'ttyusb' do
  it do
    is_expected.to contain_systemd__udev__rule('90-tty-usb.rules').with(
      rules: [
        'KERNEL=="ttyUSB[0-9]*", GROUP="70014", MODE="0660"',
      ],
    )
  end
end

# frozen_string_literal: true

shared_examples 'ftdi' do
  it do
    is_expected.to contain_systemd__udev__rule('ftdi.rules').with(
      rules: [
        'SUBSYSTEMS=="usb", ATTRS{idVendor}=="0403", GROUP="70014", MODE="0660"',
      ]
    )
  end
end

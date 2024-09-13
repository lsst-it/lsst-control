# frozen_string_literal: true

shared_examples 'fiberspec' do
  it do
    is_expected.to contain_systemd__udev__rule('fiberspec.rules').with(
      rules: [
        'SUBSYSTEM=="usb", ATTR{idVendor}=="1992", ATTR{idProduct}=="0667", ACTION=="add", GROUP="saluser", MODE="0664"',
      ]
    )
  end
end

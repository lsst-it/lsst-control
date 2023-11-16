# frozen_string_literal: true

shared_examples 'gpio' do
  it do
    is_expected.to contain_systemd__udev__rule('gpio.rules').with(
      rules: [
        'SUBSYSTEM=="gpio",NAME="gpiochip%n",GROUP="gpio",MODE="0660"',
      ],
    )
  end

  it do
    is_expected.to contain_group('gpio').with(
      ensure: 'present',
      forcelocal: true,
      system: true,
    )
  end

  it { is_expected.to contain_package('libgpiod-utils') }
end

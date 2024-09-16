# frozen_string_literal: true

shared_examples 'gpio' do |os_facts:|
  it do
    is_expected.to contain_systemd__udev__rule('gpio.rules').with(
      rules: [
        'SUBSYSTEM=="gpio",NAME="gpiochip%n",GROUP="gpio",MODE="0660"',
      ]
    )
  end

  it do
    is_expected.to contain_group('gpio').with(
      ensure: 'present',
      forcelocal: true,
      system: true
    )
  end

  if os_facts[:os]['family'] == 'RedHat' && os_facts[:os]['release']['major'] == '9'
    it { is_expected.to contain_package('libgpiod-utils') }
  else
    it { is_expected.not_to contain_package('libgpiod-utils') }
  end
end

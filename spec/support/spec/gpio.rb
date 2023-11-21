# frozen_string_literal: true

shared_examples 'gpio' do |os_facts:|
  it do
    is_expected.to contain_systemd__udev__rule('gpio.rules').with(
      rules: [
        'SUBSYSTEM=="gpio",NAME="gpiochip%n",GROUP="gpio",MODE="0660"',
      ],
    )
  end

  if os_facts[:os]['family'] == 'RedHat' && os_facts[:os]['release']['major'] == '7'
    it do
      is_expected.to contain_systemd__udev__rule('gpio-el7.rules').with(
        rules: [
          <<~'RULE',
          SUBSYSTEM=="gpio*", PROGRAM="/bin/sh -c '\
            chown -R root:gpio /sys/class/gpio && chmod -R 770 /sys/class/gpio;\
            chown -R root:gpio /sys/devices/virtual/gpio && chmod -R 770 /sys/devices/virtual/gpio;\
            chown -R root:gpio /sys$devpath && chmod -R 770 /sys$devpath\
          '"
          RULE
        ],
      )
    end
  end

  it do
    is_expected.to contain_group('gpio').with(
      ensure: 'present',
      forcelocal: true,
      system: true,
    )
  end

  if os_facts[:os]['family'] == 'RedHat' && os_facts[:os]['release']['major'] == '9'
    it { is_expected.to contain_package('libgpiod-utils') }
  else
    it { is_expected.not_to contain_package('libgpiod-utils') }
  end
end

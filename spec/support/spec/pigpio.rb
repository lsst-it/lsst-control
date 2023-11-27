# frozen_string_literal: true

shared_examples 'pigpio' do
  it { is_expected.to contain_yumrepo('raspberry-pi') }
  it { is_expected.to contain_package('pigpio').that_requires('Yumrepo[raspberry-pi]') }
  it { is_expected.to contain_file('/etc/sysconfig/pigpiod') }
  it { is_expected.to contain_systemd__unit_file('pigpiod.service') }

  it do
    is_expected.to contain_service('pigpiod')
      .that_subscribes_to('Systemd::Unit_file[pigpiod.service]')
      .that_subscribes_to('File[/etc/sysconfig/pigpiod]')
      .that_subscribes_to('Package[pigpio]')
  end
end

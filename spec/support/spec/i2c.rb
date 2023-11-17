# frozen_string_literal: true

shared_examples 'i2c' do |os_facts:|
  it do
    is_expected.to contain_systemd__udev__rule('i2c.rules').with(
      rules: [
        'KERNEL=="i2c-[0-9]*", GROUP="i2c", MODE="0660"',
      ],
    )
  end

  it do
    is_expected.to contain_group('i2c').with(
      ensure: 'present',
      forcelocal: true,
      system: true,
    )
  end

  it { is_expected.to contain_package('i2c-tools') }

  if os_facts[:os]['family'] == 'RedHat' && os_facts[:os]['release']['major'] == '9'
    it { is_expected.to contain_package('python3-i2c-tools') }
  end

  it { is_expected.to contain_kmod__load('i2c-dev') }

  if os_facts[:cpuinfo]&.[]('processor')&.[]('Model') =~ %r{Raspberry Pi}
    it do
      is_expected.to contain_profile__pi__config__fragment('i2c').with(
        content: 'dtparam=i2c_arm=on',
      )
    end
  end
end

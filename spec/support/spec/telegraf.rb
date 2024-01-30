# frozen_string_literal: true

shared_examples 'telegraf' do
  it do
    is_expected.to contain_class('telegraf').with(
      ensure: 'absent',
    )
  end

  it { is_expected.to contain_file('/etc/telegraf/telegraf.d').with_purge(true) }
end

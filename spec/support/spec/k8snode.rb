# frozen_string_literal: true

shared_examples 'k8snode profile' do
  it { is_expected.to contain_package('gdisk') }

  it do
    is_expected.to contain_sysctl__value('fs.inotify.max_user_instances').with(
      value: 104_857,
      target: '/etc/sysctl.d/80-rke.conf',
    )
  end

  it do
    is_expected.to contain_sysctl__value('fs.inotify.max_user_watches').with(
      value: 1_048_576,
      target: '/etc/sysctl.d/80-rke.conf',
    )
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::podman::prune' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it 'creates the podman_prune cron job' do
        is_expected.to contain_cron__job('podman_prune').with(
          minute:      '0',
          hour:        '16',
          date:        '*',
          month:       '*',
          weekday:     '*',
          user:        'root',
          command:     'systemd-cat -t podman-prune podman system prune -a --filter "until=$((14*24))h" --force',
          environment: ['PATH="/bin"'],
          description: 'Run podman system prune'
        )
      end
    end
  end
end

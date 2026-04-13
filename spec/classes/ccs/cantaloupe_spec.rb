# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ccs::cantaloupe' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) do
        {
          pkgurl: 'https://example.org',
          pkgurl_user: sensitive('user'),
          pkgurl_pass: sensitive('pass'),
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_file('/data/cantaloupe').with_ensure('directory') }
      it { is_expected.to contain_file('/data/cantaloupe/cache').with_ensure('directory') }
      it { is_expected.to contain_file('/data/cantaloupe/images').with_ensure('directory') }

      it { is_expected.to contain_file('/home/ccs/cantaloupe').with_ensure('directory') }
      it { is_expected.to contain_file('/home/ccs/cantaloupe/cantaloupe-5.0').with_ensure('directory') }
      it { is_expected.to contain_file('/home/ccs/cantaloupe/cantaloupe-5.0/cache').with_ensure('link') }
      it { is_expected.to contain_file('/home/ccs/cantaloupe/cantaloupe-5.0/images').with_ensure('link') }
      it { is_expected.to contain_file('/home/ccs/cantaloupe/cantaloupe-5.0/delegates.rb').with_mode('0644') }
      it { is_expected.to contain_file('/home/ccs/cantaloupe/cantaloupe-5.0/mem-monitor').with_mode('0755') }
      it { is_expected.to contain_file('/home/ccs/cantaloupe/cantaloupe-5.0/cantaloupe.properties').with_mode('0644') }
      it { is_expected.to contain_file('/home/ccs/cantaloupe/cantaloupe-5.0/cantaloupe-5.0.4.jar').with_mode('0644') }

      it do
        is_expected.to contain_service('cantaloupe').with(
          ensure: 'running',
          enable: true,
        )
      end

      it 'creates the cantaloupe_mem_monitor cron job' do
        is_expected.to contain_cron__job('cantaloupe_mem_monitor').with(
          minute:      '*',
          hour:        '*',
          date:        '*',
          month:       '*',
          weekday:     '*',
          user:        'ccs',
          command:     'cd /home/ccs/cantaloupe/cantaloupe-5.0 && ./mem-monitor',
          environment: ['PATH="/bin"'],
          description: 'Check cantaloupe memory usage',
        )
      end
    end
  end
end

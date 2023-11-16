# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::lhnrouting' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      if os_facts[:os]['release']['major'] == '7'
        it { is_expected.to contain_kmod__load('dummy') }

        it do
          is_expected.to contain_kmod__install('dummy').with(
            command: '"/sbin/modprobe --ignore-install dummy; /sbin/ip link set name lhnrouting dev dummy0"',
          )
        end
      else
        it { is_expected.not_to contain_kmod__load('dummy') }
        it { is_expected.not_to contain_kmod__install('dummy') }
      end
    end
  end
end

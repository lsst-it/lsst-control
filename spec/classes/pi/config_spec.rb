# frozen_string_literal: true

require 'spec_helper'

describe 'profile::pi::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_concat('/boot/config.txt').with_mode('0755') }
      it { is_expected.to contain_reboot('/boot/config.txt') }

      context 'with fragments param' do
        let(:params) do
          {
            fragments: {
              'foo' => {
                'content' => 'foo=bar',
              },
              'baz' => {
                'content' => 'baz=quix',
              },
            },
          }
        end

        it { is_expected.to contain_concat__fragment('foo').with_content('foo=bar') }
        it { is_expected.to contain_concat__fragment('baz').with_content('baz=quix') }
      end

      context 'with reboot => false' do
        let(:params) do
          {
            reboot: false,
          }
        end

        it { is_expected.not_to contain_reboot('/boot/config.txt') }
      end
    end
  end
end

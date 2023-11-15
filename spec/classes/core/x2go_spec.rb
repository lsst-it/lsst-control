# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::x2go' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) do
        <<~PP
        sudo::conf { 'bogus':
          content => '%foo ALL=(bar) NOPASSWD: ALL',
        }
        PP
      end

      context 'with no parameters' do
        it { is_expected.to compile.with_all_deps }

        include_examples 'x2go packages', os_facts: os_facts

        it do
          is_expected.to contain_file('/etc/sudoers.d/x2goserver')
            .that_comes_before('Sudo::Conf[bogus]')
        end
      end
    end
  end
end

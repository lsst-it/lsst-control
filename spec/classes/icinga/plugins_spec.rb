# frozen_string_literal: true

require 'spec_helper'

describe 'profile::icinga::plugins' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:pre_condition) do
        <<~PP
        include icingaweb2
        PP
      end

      let(:params) do
        {
          credentials_hash: 'foo',
        }
      end

      context 'with all required params' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('autoconf') }
        it { is_expected.to contain_package('automake') }

        it do
          is_expected.to contain_exec('autoreconf')
            .that_requires('Package[autoconf]')
            .that_requires('Package[automake]')
        end
      end
    end
  end
end

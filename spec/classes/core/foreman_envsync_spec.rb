# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::foreman_envsync' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_package('devtoolset-7') }
      it { is_expected.to contain_package('rh-ruby27-ruby-devel') }

      it do
        is_expected.to contain_exec('install foreman_envsync').with(
          command: '/bin/scl enable devtoolset-7 tfm -- gem install --version 1.1.1 --bindir /bin --ignore-dependencies --no-document foreman_envsync',
        )
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ccs::sal_dx' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with no params' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_yumrepo('lsst-ts-private') }

        it do
          is_expected.to contain_package('OpenSpliceDDS')
            .that_requires('Yumrepo[lsst-ts-private]')
        end
      end
    end
  end
end

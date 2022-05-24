# frozen_string_literal: true

require 'spec_helper'

describe 'test1.dev.lsst.org', :site do
  describe 'm2 role' do
    lsst_sites.each do |site|
      context "with site #{site}" do
        let(:node_params) do
          {
            site: site,
            role: 'm2',
            ipa_force_join: false, # easy_ipa
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('profile::core::common') }
        it { is_expected.to contain_class('profile::core::debugutils') }
        it { is_expected.to contain_class('profile::core::ni_packages') }
        it { is_expected.to contain_class('profile::core::x2go_agent') }
        it { is_expected.to contain_class('profile::ts::opensplicedds') }
        it { is_expected.to contain_yumrepo('lsst-ts-private') }

        it do
          is_expected.to contain_package('OpenSpliceDDS')
            .that_requires('Yumrepo[lsst-ts-private]')
        end
      end
    end # site
  end # role
end

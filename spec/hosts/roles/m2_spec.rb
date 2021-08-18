# frozen_string_literal: true

require 'spec_helper'

describe 'test1.dev.lsst.org', :site do
  describe 'm2 role' do
    lsst_sites.each do |site|
      context "with site #{site}" do
        let(:node_params) do
          {
            org: 'lsst',
            site: site,
            role: 'm2',
            ipa_force_join: false, # easy_ipa
          }
        end

        it do
          # is_host_example
          is_expected.to compile.with_all_deps
        end

        it { is_expected.to contain_class('profile::core::common') }
        it { is_expected.to contain_class('profile::core::debugutils') }
        it { is_expected.to contain_class('profile::core::ni_packages') }
        it { is_expected.to contain_class('profile::core::x2go_agent') }
      end
    end # site
  end  # role
end

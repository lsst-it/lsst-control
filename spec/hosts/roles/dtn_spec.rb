# frozen_string_literal: true

require 'spec_helper'

describe 'test1.dev.lsst.org', :site do
  describe 'dtn role' do
    lsst_sites.each do |site|
      context "with site #{site}" do
        let(:node_params) do
          {
            org: 'lsst',
            site: site,
            role: 'dtn',
            ipa_force_join: false, # easy_ipa
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('profile::core::common') }
        it { is_expected.to contain_class('profile::core::dtn') }

        it do
          is_expected.to contain_class('ssh').with(
            server_options: { 'Port' => [22, 2712] },
          )
        end
      end
    end # site
  end # role
end

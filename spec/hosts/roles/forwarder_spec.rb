# frozen_string_literal: true

require 'spec_helper'

describe 'test1.dev.lsst.org', :site do
  describe 'forwarder role' do
    lsst_sites.each do |site|
      context "with site #{site}" do
        let(:node_params) do
          {
            org: 'lsst',
            site: site,
            role: 'forwarder',
            cluster: 'comcam-archive',
            ipa_force_join: false, # easy_ipa
          }
        end

        it { is_expected.to compile.with_all_deps }

        include_examples 'lhn sysctls'

        it { is_expected.to contain_package('git') }
      end
    end # site
  end # role
end

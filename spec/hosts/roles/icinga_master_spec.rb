# frozen_string_literal: true

require 'spec_helper'

describe 'test1.dev.lsst.org', :site do
  describe 'icinga-master role' do
    lsst_sites.each do |site|
      context "with site #{site}" do
        let(:node_params) do
          {
            org: 'lsst',
            site: site,
            role: 'icinga-master',
            ipa_force_join: false, # easy_ipa
          }
        end

        it { is_expected.to compile.with_all_deps }
      end
    end # site
  end # role
end

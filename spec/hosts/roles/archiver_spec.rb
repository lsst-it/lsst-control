# frozen_string_literal: true

require 'spec_helper'

describe 'test1.dev.lsst.org', :site do
  describe 'archiver role' do
    lsst_sites.each do |site|
      context "with site #{site}" do
        let(:node_params) do
          {
            org: 'lsst',
            site: site,
            role: 'archiver',
            ipa_force_join: false, # easy_ipa
          }
        end

        it { is_expected.to compile.with_all_deps }

        include_examples 'lhn sysctls'
        include_examples 'archiver'
      end
    end # site
  end # role
end

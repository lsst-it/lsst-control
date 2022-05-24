# frozen_string_literal: true

require 'spec_helper'

describe 'test1.dev.lsst.org', :site do
  role = 'hexrot'
  let(:role) { role }

  describe "#{role} role" do
    lsst_sites.each do |site|
      context "with site #{site}" do
        let(:node_params) do
          {
            site: site,
            role: role,
            ipa_force_join: false, # easy_ipa
          }
        end

        it { is_expected.to compile.with_all_deps }

        %w[
          profile::core::common
          profile::core::debugutils
          profile::core::docker
          profile::core::docker::prune
          profile::core::ni_packages
          profile::core::x2go_agent
          python
        ].each do |c|
          it { is_expected.to contain_class(c) }
        end
      end
    end # site
  end # role
end

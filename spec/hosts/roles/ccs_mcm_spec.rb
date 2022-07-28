# frozen_string_literal: true

require 'spec_helper'

role = 'generic'

describe "#{role} role" do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: self.class.description,
        )
      end

      %w[
        comcam-ccs
        auxtel-ccs
      ].each do |cluster|
        context "#{cluster} cluster" do
          let(:node_params) do
            {
              role: role,
              site: site,
              cluster: cluster,
            }
          end

          lsst_sites.each do |site|
            describe "#{role}.#{site}.lsst.org", :site, :common do
              let(:site) { site }

              it { is_expected.to compile.with_all_deps }
            end # host
          end # lsst_sites
        end # cluster
      end # cluster
    end # on os
  end # on_supported_os
end # role

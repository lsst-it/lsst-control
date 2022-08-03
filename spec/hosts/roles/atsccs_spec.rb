# frozen_string_literal: true

require 'spec_helper'

role = 'atsccs'

describe "#{role} role" do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: self.class.description,
        )
      end

      let(:node_params) do
        {
          role: role,
          site: site,
          cluster: 'auxtel-ccs',
        }
      end

      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :site, :common do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('ccs_sal') }
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role

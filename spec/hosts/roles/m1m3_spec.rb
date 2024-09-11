# frozen_string_literal: true

require 'spec_helper'

role = 'm1m3'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :sitepp do
          let(:node_params) do
            {
              role: role,
              site: site,
            }
          end
          let(:facts) { lsst_override_facts(os_facts) }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', os_facts: os_facts, site: site
          include_examples 'x2go packages', os_facts: os_facts
          it { is_expected.to contain_class('mate') }

          %w[
            catch-devel
            yaml-cpp-devel
          ].each do |pkg|
            it do
              is_expected.to contain_package(pkg)
            end
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role

# frozen_string_literal: true

require 'spec_helper'

role = 'it-ansible'

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
        }
      end

      let(:pre_condition) do
        <<~PP
          file { '/opt/ansible/.ssh/id_rsa': }
        PP
      end

      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :site do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role

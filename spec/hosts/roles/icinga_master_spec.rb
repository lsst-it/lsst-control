# frozen_string_literal: true

require 'spec_helper'

role = 'icinga-master'

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

      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :site do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts

          it do
            is_expected.to contain_nginx__resource__server('icingaweb2').with(
              ssl_cert: %r{fullchain.pem$},
            )
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role

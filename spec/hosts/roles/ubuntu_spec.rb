# frozen_string_literal: true

require 'spec_helper'

role = 'ubuntu'

describe "#{role} role" do
  test_on = {
    supported_os: [
      {
        'operatingsystem' => 'Ubuntu',
        'operatingsystemrelease' => ['20.04', '22.04'],
      },
    ],
  }

  on_supported_os(test_on).each do |os, facts|
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
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role
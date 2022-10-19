# frozen_string_literal: true

require 'spec_helper'

PUPPETDB_VERSION = '7.11.0'

shared_examples 'puppetdb' do
  it { is_expected.to contain_yum__versionlock('puppetdb').with_version(PUPPETDB_VERSION) }
  it { is_expected.to contain_class('puppetdb::globals').with_version(PUPPETDB_VERSION) }
end

role = 'puppetdb'

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
          include_examples 'puppetdb'
        end # host
      end # lsst_sites
    end
  end
end

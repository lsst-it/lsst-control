# frozen_string_literal: true

require 'spec_helper'

role = 'dnscache'

describe "#{role} role" do
  on_supported_os.each do |os, facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) { facts.merge(fqdn: self.class.description) }
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
            is_expected.to contain_class('dns').with(
              forwarders: [
                '1.0.0.1',
                '1.1.1.1',
                '8.8.8.8',
              ],
            )
          end

          it do
            expect(catalogue.resource('class', 'dns')[:additional_directives]).to include(match(%r{^\s+severity notice;$}))
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role

# frozen_string_literal: true

require 'spec_helper'

role = 'm2'

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
          include_examples 'x2go packages', facts: facts
          it { is_expected.to contain_class('profile::core::common') }
          it { is_expected.to contain_class('profile::core::debugutils') }
          it { is_expected.to contain_class('profile::core::ni_packages') }
          it { is_expected.to contain_class('profile::ts::opensplicedds') }
          it { is_expected.to contain_yumrepo('lsst-ts-private') }

          it do
            is_expected.to contain_package('OpenSpliceDDS')
              .that_requires('Yumrepo[lsst-ts-private]')
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role

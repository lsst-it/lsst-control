# frozen_string_literal: true

require 'spec_helper'

role = 'm2'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :sitepp do
          let(:node_params) do
            {
              role:,
              site:,
            }
          end
          let(:facts) { lsst_override_facts(os_facts) }

          it { is_expected.to compile.with_all_deps }

          include_examples('common', os_facts:, site:)
          include_examples('x2go packages', os_facts:)
          it { is_expected.to contain_class('mate') }
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

# frozen_string_literal: true

require 'spec_helper'

role = 'openvpnas'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

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

          it do
            is_expected.to contain_class('openvpnas').with(
              version: '3.0.2_87c70987'
            )
          end

          it { is_expected.to contain_openvpnas__config__group('vpn-default') }
          it { is_expected.to contain_openvpnas__config__group('vpn-it') }
          it { is_expected.to contain_openvpnas__config__group('vpn-science') }
          it { is_expected.to contain_openvpnas__config__group('vpn-cucm') }
          it { is_expected.to contain_openvpnas__config__group('vpn-tssw') }
          it { is_expected.to contain_openvpnas__config__group('vpn-comm') }
          it { is_expected.to contain_openvpnas__config__group('vpn-clyso') }
          it { is_expected.to contain_openvpnas__config__group('vpn-users') }

          include_examples('common', os_facts:, site:)
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role

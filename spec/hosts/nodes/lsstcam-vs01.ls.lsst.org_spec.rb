# frozen_string_literal: true

require 'spec_helper'

#
# note that this hosts has interfaces with an mtu of 9000
#
describe 'lsstcam-vs01.ls.lsst.org', :site do
  alma8 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '8' }).first
  # rubocop:disable Naming/VariableNumber
  { 'almalinux-8-x86_64': alma8 }.each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'lsstcam-vs01.ls.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'ccs-generic',
          site: 'ls',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_context 'with nm interface'

      it { is_expected.to have_network__interface_resource_count(0) }
      it { is_expected.to have_profile__nm__connection_resource_count(5) }

      %w[
        eno1np0
        eno2np1
        enp4s0f3u2u2c2
        enp129s0f1
      ].each do |i|
        context "with #{name}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with enp129s0f0' do
        let(:interface) { 'enp129s0f0' }

        it_behaves_like 'nm named interface'
        it_behaves_like 'nm dhcp interface'
        it { expect(nm_keyfile['connection']['type']).to eq('ethernet') }
        it { expect(nm_keyfile['connection']['autoconnect']).to be_nil }
      end
    end # on os
  end # on_supported_os
end

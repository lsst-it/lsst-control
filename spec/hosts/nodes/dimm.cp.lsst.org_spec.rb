# frozen_string_literal: true

require 'spec_helper'

describe 'dimm.cp.lsst.org', :site do
  alma8 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '8' }).first
  # rubocop:disable Naming/VariableNumber
  { 'almalinux-8-x86_64': alma8 }.each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) { override_facts(facts, fqdn: 'dimm.cp.lsst.org') }
      let(:node_params) do
        {
          role: 'generic',
          site: 'cp',
        }
      end

      include_context 'with nm interface'

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to have_network__interface_resource_count(0) }
      it { is_expected.to have_profile__nm__connection_resource_count(2) }

      context 'with eno1' do
        let(:interface) { 'eno1' }

        it_behaves_like 'nm named interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with enp2s0' do
        let(:interface) { 'enp2s0' }

        it_behaves_like 'nm disabled interface'
      end
    end # on os
  end # on_supported_os
end

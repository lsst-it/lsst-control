# frozen_string_literal: true

require 'spec_helper'

describe 'core03.dev.lsst.org', :sitepp do
  alma9 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '9' }).first
  # rubocop:disable Naming/VariableNumber
  { 'almalinux-9-x86_64': alma9 }.each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) do
        override_facts(facts,
                       fqdn: 'core03.dev.lsst.org',
                       is_virtual: false,
                       dmi: {
                         'product' => {
                           'name' => 'AS -1114S-WN10RT',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'hypervisor',
          site: 'dev',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples('baremetal',
                       bmc: {
                         lan1: {
                           ip: '139.229.134.37',
                           netmask: '255.255.255.0',
                           gateway: '139.229.134.254',
                           type: 'static',
                         },
                       })
      include_context 'with nm interface'

      it { is_expected.to have_network__interface_resource_count(0) }
      it { is_expected.to have_profile__nm__connection_resource_count(8) }

      context 'with enp1s0f0' do
        let(:interface) { 'enp1s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.134.34/24,139.229.134.254') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.134.53;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('dev.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
      end
    end # on os
  end # on_supported_os
end

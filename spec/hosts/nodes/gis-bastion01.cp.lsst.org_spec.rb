# frozen_string_literal: true

require 'spec_helper'

describe 'gis-bastion01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'gis-bastion01.cp.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'AS -1114S-WN10RT',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'bastion',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(2) }

      context 'with enp1s0f0' do
        let(:interface) { 'enp1s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end

      context 'with enp1s0f1' do
        let(:interface) { 'enp1s0f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('192.168.180.230/24') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end
    end # on os
  end # on_supported_os
end

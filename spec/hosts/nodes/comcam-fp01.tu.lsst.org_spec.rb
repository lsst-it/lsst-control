# frozen_string_literal: true

require 'spec_helper'

describe 'comcam-fp01.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'comcam-fp01.tu.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R640',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'comcam-fp',
          site: 'tu',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(2) }

      context 'with ens1f0' do
        let(:interface) { 'ens1f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end

      context 'with ens3f1' do
        let(:interface) { 'ens3f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('192.168.100.15/24') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
        it { expect(nm_keyfile['ipv6']['method']).to eq('disabled') }
      end
    end # on os
  end # on_supported_os
end

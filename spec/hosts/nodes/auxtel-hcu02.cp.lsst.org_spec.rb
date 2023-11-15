# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-hcu02.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(facts,
                       fqdn: 'auxtel-hcu02.cp.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'UNO-1483G-434AE',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'atshcu',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal no bmc'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(4) }

      context 'with eno1' do
        let(:interface) { 'eno1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with enp8s0' do
        let(:interface) { 'enp8s0' }

        it_behaves_like 'nm disabled interface'
      end

      context 'with enp7s0' do
        let(:interface) { 'enp7s0' }

        it_behaves_like 'nm disabled interface'
      end

      context 'with enp6s0' do
        let(:interface) { 'enp6s0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('192.168.1.1/24') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
      end
    end # on os
  end # on_supported_os
end

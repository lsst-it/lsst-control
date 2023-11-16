# frozen_string_literal: true

require 'spec_helper'

describe 'azar03.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'azar03.cp.lsst.org',
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
          role: 'dco',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'

      it do
        is_expected.to contain_class('docker::networks').with(
          'networks' => {
            'dds-network' => {
              'ensure' => 'present',
              'driver' => 'macvlan',
              'subnet' => '139.229.178.0/24',
              'gateway' => '139.229.178.254',
              'options' => ['parent=dds'],
            },
          },
        )
      end

      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(4) }

      context 'with enp1s0f0' do
        let(:interface) { 'enp1s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['method']).to eq('disabled') }
      end

      context 'with enp1s0f1' do
        let(:interface) { 'enp1s0f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ethernet']['mtu']).to eq(9000) }
      end

      context 'with dds' do
        let(:interface) { 'dds' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm bridge interface'
      end

      context 'with startracker' do
        let(:interface) { 'startracker' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bridge interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.169.1/24,139.229.169.254') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.160.53;139.229.160.54;139.229.160.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('cp.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['never-default']).to be(true) }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
        it { expect(nm_keyfile['ethernet']['mtu']).to eq(9000) }
      end

      it do
        is_expected.to contain_nfs__client__mount('/net/project').with(
          share: 'project',
          server: 'nfs1.cp.lsst.org',
          atboot: true,
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/net/scratch').with(
          share: 'scratch',
          server: 'nfs1.cp.lsst.org',
          atboot: true,
        )
      end
    end # on os
  end # on_supported_os
end

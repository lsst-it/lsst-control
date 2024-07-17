# frozen_string_literal: true

require 'spec_helper'

describe 'tel-hw1.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'tel-hw1.tu.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'Super Server',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'amor',
          site: 'tu',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal no bmc'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(3) }

      context 'with ens6f0' do
        let(:interface) { 'ens6f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with ens6f1' do
        let(:interface) { 'ens6f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm bridge slave interface', master: 'dds'
      end

      context 'with dds' do
        let(:interface) { 'dds' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bridge interface'
        it_behaves_like 'nm manual interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('140.252.147.135/27') }
        it { expect(nm_keyfile['ipv4']['route1']).to eq('140.252.147.16/28,140.252.147.129') }
        it { expect(nm_keyfile['ipv4']['route2']).to eq('140.252.147.48/28,140.252.147.129') }
      end

      it { is_expected.to contain_class('nfs').with_server_enabled(false) }
      it { is_expected.to contain_class('nfs').with_client_enabled(true) }

      it do
        is_expected.to contain_nfs__client__mount('/data').with(
          share: 'obs-env',
          server: 'nfs-obsenv.tu.lsst.org',
          atboot: true,
        )
      end
    end # on os
  end # on_supported_os
end

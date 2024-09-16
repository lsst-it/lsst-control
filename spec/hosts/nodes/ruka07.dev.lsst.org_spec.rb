# frozen_string_literal: true

require 'spec_helper'

#
# primarily testing cluster/ruka/variant/r430; for ruka cluster layer spec see
# ruka01.dev.lsst.org.yaml
#
describe 'ruka07.dev.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'PowerEdge C6420',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'rke2agent',
          site: 'dev',
          cluster: 'ruka',
          variant: 'c6420',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_examples 'ceph cluster'

      it do
        expect(catalogue.resource('class', 'rke2')[:config]).to include(
          'node-label' => ['role=storage-node']
        )
      end

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'ruka' => {
              'group' => 'ruka',
              'member' => [
                'ruka[01-05]',
                'ruka[07-08]',
              ],
            },
          }
        )
      end

      it do
        is_expected.to contain_class('rke2').with(
          node_type: 'agent',
          release_series: '1.28',
          version: '1.28.12~rke2r1'
        )
      end

      it { is_expected.to contain_class('cni::plugins::dhcp::service') }

      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(5) }

      context 'with ens4f0' do
        let(:interface) { 'ens4f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with ens4f0.2101' do
        let(:interface) { 'ens4f0.2101' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 2101, parent: 'ens4f0'
        it_behaves_like 'nm bridge slave interface', master: 'br2101'
      end

      context 'with br2101' do
        let(:interface) { 'br2101' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm no-ip interface'
        it_behaves_like 'nm bridge interface'
      end

      context 'with ens4f0.2505' do
        let(:interface) { 'ens4f0.2505' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 2505, parent: 'ens4f0'
        it_behaves_like 'nm bridge slave interface', master: 'br2505'
      end

      context 'with br2505' do
        let(:interface) { 'br2505' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm no-ip interface'
        it_behaves_like 'nm bridge interface'
        it { expect(nm_keyfile['ipv4']['route1']).to eq('139.229.153.0/24') }
        it { expect(nm_keyfile['ipv4']['route1_options']).to eq('table=2505') }
        it { expect(nm_keyfile['ipv4']['route2']).to eq('0.0.0.0/0,139.229.153.254') }
        it { expect(nm_keyfile['ipv4']['route2_options']).to eq('table=2505') }
        it { expect(nm_keyfile['ipv4']['routing-rule1']).to eq('priority 100 from 139.229.153.64/26 table 2505') }
      end
    end # on os
  end # on_supported_os
end

# frozen_string_literal: true

require 'spec_helper'

#
# testing cluster/ruka & cluster/ruka/variant/r440
#
describe 'ruka01.dev.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'ruka01.dev.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R440',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'rke',
          site: 'dev',
          cluster: 'ruka',
          variant: 'r440',
        }
      end
      let(:vlan_id) { 2505 }
      let(:rt_id) { vlan_id }

      it { is_expected.to compile.with_all_deps }

      include_examples 'docker', docker_version: '24.0.9'
      include_examples 'baremetal'

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'ruka' => {
              'group' => 'ruka',
              'member' => 'ruka[01-05]',
            },
          },
        )
      end

      it do
        is_expected.to contain_class('rke').with(
          version: '1.5.8',
        )
      end

      it do
        is_expected.to contain_class('cni::plugins').with(
          version: '1.2.0',
          checksum: 'f3a841324845ca6bf0d4091b4fc7f97e18a623172158b72fc3fdcdb9d42d2d37',
          enable: ['macvlan'],
        )
      end

      it { is_expected.to contain_class('cni::plugins::dhcp') }

      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(6) }

      %w[
        eno1
        eno2
        ens2f0
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with ens2f1' do
        let(:interface) { 'ens2f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with ens2f0.2505' do
        let(:interface) { 'ens2f0.2505' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 2505, parent: 'ens2f0'
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

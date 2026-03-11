# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-dc1.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'AS -1115HS-TNR',
                              },
                            })
      end

      let(:node_params) do
        {
          role: 'ccs-dc',
          cluster: 'lsstcam-ccs',
          site: 'cp',
          variant: '1115s',
          subvariant: 'lsst-daq',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it_behaves_like 'lsstcam-rsyslog'
      it_behaves_like 'lsstcam-dc.cp'
      it_behaves_like 'baremetal'
      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(11) }

      %w[
        enp73s0f4u1u1c2
        ens2f1np1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      %w[
        enp34s0f0
        enp34s0f1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm named interface'
          it_behaves_like 'nm ethernet interface'
          it_behaves_like 'nm no-ip interface'
          it { expect(nm_keyfile['connection']['master']).to eq('bond0') }
          it { expect(nm_keyfile['connection']['slave-type']).to eq('bond') }
          it { expect(nm_keyfile_raw).to match(%r{^\[ethernet\]$}) }
          it { expect(nm_keyfile_raw).to match(%r{^\[ipv4\]$}) }
          it { expect(nm_keyfile_raw).to match(%r{^\[ipv6\]$}) }
        end
      end

      context 'with bond0' do
        let(:interface) { 'bond0' }

        it_behaves_like 'nm named interface'
        it_behaves_like 'nm no-ip interface'
        it { expect(nm_keyfile['connection']['type']).to eq('bond') }
        it { expect(nm_keyfile['bond']['miimon']).to eq(100) }
        it { expect(nm_keyfile['bond']['mode']).to eq('802.3ad') }
        it { expect(nm_keyfile['bond']['xmit_hash_policy']).to eq('layer3+4') }
        it { expect(nm_keyfile_raw).to match(%r{^\[ethernet\]$}) }
        it { expect(nm_keyfile_raw).not_to match(%r{^\[proxy\]$}) }
      end

      %w[
        1511
        1701
      ].each do |vlan|
        iface = "bond0.#{vlan}"

        context "with #{iface}" do
          let(:interface) { iface }

          it_behaves_like 'nm enabled interface'
          it_behaves_like 'nm vlan interface', id: vlan.to_i, parent: 'bond0'
          it_behaves_like 'nm bridge slave interface', master: "br#{vlan}"
        end
      end

      context 'with br1511' do
        let(:interface) { 'br1511' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bridge interface'
        it_behaves_like 'nm manual interface'

        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.175.101/26,139.229.175.126') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.160.53;139.229.160.54;139.229.160.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('cp.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
      end

      context 'with br1701' do
        let(:interface) { 'br1701' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bridge interface'
        it_behaves_like 'nm manual interface'

        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.173.142/27,139.229.173.129') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.160.53;139.229.160.54;139.229.160.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('cp.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
        it { expect(nm_keyfile['ipv4']['route1']).to eq('172.24.7.0/24,139.229.173.129') }
        it { expect(nm_keyfile['ipv4']['never-default']).to be(true) }
      end

      context 'with ens2f0np0' do
        let(:interface) { 'ens2f0np0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm bridge slave interface', master: 'lsst-daq'
      end

      context 'with lsst-daq' do
        let(:interface) { 'lsst-daq' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bridge interface'
        it_behaves_like 'nm dhcp interface'
      end
    end # on os
  end # on_supported_os
end

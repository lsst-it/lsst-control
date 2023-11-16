# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-dc01.ls.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'lsstcam-dc01.ls.lsst.org',
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
          role: 'ccs-dc',
          site: 'ls',
          cluster: 'lsstcam-ccs',
          variant: '1114s',
          subvariant: 'daq-lhn',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(10) }

      %w[
        eno1np0
        eno2np1
        enp4s0f3u2u2c2
        enp129s0f1
        enp197s0f1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with enp129s0f0' do
        let(:interface) { 'enp129s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with enp129s0f1.2505' do
        let(:interface) { 'enp129s0f1.2505' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 2505, parent: 'enp129s0f1'
        it_behaves_like 'nm bridge slave interface', master: 'lhn'
      end

      context 'with enp197s0f0' do
        let(:interface) { 'enp197s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm bridge slave interface', master: 'lsst-daq'
        it { expect(nm_keyfile['ethtool']['ring-rx']).to eq(4096) }
        it { expect(nm_keyfile['ethtool']['ring-tx']).to eq(4096) }
      end

      context 'with lhn' do
        let(:interface) { 'lhn' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bridge interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm no default route'
        it { expect(nm_keyfile['ipv4']['route1']).to eq('139.229.153.0/24') }
        it { expect(nm_keyfile['ipv4']['route1_options']).to eq('table=2505') }
        it { expect(nm_keyfile['ipv4']['route2']).to eq('0.0.0.0/0,139.229.153.254') }
        it { expect(nm_keyfile['ipv4']['route2_options']).to eq('table=2505') }
        it { expect(nm_keyfile['ipv4']['routing-rule1']).to eq('priority 100 from 139.229.153.64/26 table 2505') }
      end

      context 'with lsst-daq' do
        let(:interface) { 'lsst-daq' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm bridge interface'
      end

      it { is_expected.to contain_service('focal-plane') }

      it { is_expected.to contain_systemd__unit_file('image-handling.service').with_content(%r{^User=ccs-ipa}) }

      it { is_expected.to contain_file('/etc/ccs/image-handling.app') }

      it do
        # ccs-ipa = 72055
        is_expected.to contain_file('/data/ccs-ipa-data').with(
          ensure: 'directory',
          owner: 72_055,
          group: 72_055,
          mode: '0755',
        )
      end

      it do
        is_expected.to contain_file('/home/ccs-ipa/bin/fhe').with(
          ensure: 'file',
          owner: 'ccs-ipa',
          group: 'ccs-ipa',
          mode: '0755',
        )
      end

      it { is_expected.to contain_file('/home/ccs-ipa/bin/mc-secret').with_content(%r{^export MC_HOST_oga=}) }
    end # on os
  end # on_supported_os
end

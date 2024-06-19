# frozen_string_literal: true

require 'spec_helper'

describe 'comcam-fp01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'comcam-fp01.cp.lsst.org',
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
          site: 'cp',
          cluster: 'comcam-ccs',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(7) }

      %w[
        eno3
        eno4
        ens1f1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with eno1' do
        let(:interface) { 'eno1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with eno2' do
        let(:interface) { 'eno2' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm manual interface'
        it_behaves_like 'nm no default route'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.181.73/29,139.229.181.78') }
        it { expect(nm_keyfile['ipv4']['route1']).to eq('172.24.7.0/24,139.229.181.78') }
      end

      context 'with ens1f0' do
        let(:interface) { 'ens1f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm bridge slave interface', master: 'lsst-daq'
        it { expect(nm_keyfile['ethtool']['ring-rx']).to eq(4096) }
        it { expect(nm_keyfile['ethtool']['ring-tx']).to eq(4096) }
      end

      context 'with lsst-daq' do
        let(:interface) { 'lsst-daq' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bridge interface'
        it_behaves_like 'nm dhcp interface'
      end

      it { is_expected.to contain_class('nfs::server').with_nfs_v4(true) }
      it { is_expected.to contain_nfs__server__export('/ccs-data') }
    end # on os
  end # on_supported_os
end

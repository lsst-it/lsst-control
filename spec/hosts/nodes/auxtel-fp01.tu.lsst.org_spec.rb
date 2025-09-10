# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-fp01.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'PowerEdge R530',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'auxtel-fp',
          site: 'tu',
          cluster: 'auxtel-ccs',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'

      it do
        is_expected.to contain_s3nd__instance('tu-latiss').with(
          image: 'ghcr.io/lsst-dm/deliverator:2.3.0',
          port: 15_571,
          volumes: [
            '/data:/data',
            '/home:/home',
          ],
          env: {
            'S3ND_ENDPOINT_URL' => 'https://s3.tu.lsst.org',
          }
        )
      end

      it do
        is_expected.to contain_s3nd__instance('s3dfrgw-latiss').with(
          image: 'ghcr.io/lsst-dm/deliverator:2.3.0',
          port: 15_581,
          volumes: [
            '/data:/data',
            '/home:/home',
          ],
          env: {
            'S3ND_ENDPOINT_URL' => 'https://s3dfrgw.slac.stanford.edu',
          }
        )
      end

      it { is_expected.to have_nm__connection_resource_count(3) }

      context 'with enp5s0f0' do
        let(:interface) { 'enp5s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with enp4s0f0' do
        let(:interface) { 'enp4s0f0' }

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
        it_behaves_like 'nm manual interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('192.168.100.10/24') }
        it { expect(nm_keyfile['ipv4']['ignore-auto-dns']).to be true }
      end

      it { is_expected.to contain_class('nfs::server').with_nfs_v4(true) }
      it { is_expected.to contain_nfs__server__export('/data') }

      it do
        is_expected.to contain_nfs__client__mount('/net/self/data').with(
          share: 'data',
          server: 'auxtel-fp01.tu.lsst.org',
          atboot: true
        )
      end
    end # on os
  end # on_supported_os
end # role

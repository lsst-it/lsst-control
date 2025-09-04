# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-fp01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'auxtel-fp01.cp.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R630',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'auxtel-fp',
          cluster: 'auxtel-ccs',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'

      it do
        is_expected.to contain_s3nd__instance('cp-latiss').with(
          image: 'ghcr.io/lsst-dm/deliverator:2.1.0',
          port: 15_571,
          volumes: [
            '/data:/data',
            '/home:/home',
          ],
          env: {
            'S3ND_ENDPOINT_URL' => 'https://s3.cp.lsst.org',
          }
        )
      end

      it do
        is_expected.to contain_s3nd__instance('sdfembs3-latiss').with(
          image: 'ghcr.io/lsst-dm/deliverator:2.1.0',
          port: 15_581,
          volumes: [
            '/data:/data',
            '/home:/home',
          ],
          env: {
            'S3ND_ENDPOINT_URL' => 'https://sdfembs3.sdf.slac.stanford.edu',
          }
        )
      end

      it { is_expected.to have_nm__connection_resource_count(5) }

      %w[
        eno2
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with eno1' do
        let(:interface) { 'eno1' }

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
        it { expect(nm_keyfile['ipv4']['address1']).to eq('192.168.100.251/24') }
      end

      context 'with eno3' do
        let(:interface) { 'eno3' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.181.74/29,139.229.181.78') }
        it { expect(nm_keyfile['ipv4']['route1']).to eq('172.24.7.0/24,139.229.181.78') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.160.53;139.229.160.54;139.229.160.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('cp.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
      end

      context 'with eno4' do
        let(:interface) { 'eno4' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      it { is_expected.to contain_host('sdfembs3.sdf.slac.stanford.edu').with_ip('172.24.7.249') }
      it { is_expected.to contain_class('nfs::server').with_nfs_v4(true) }
      it { is_expected.to contain_nfs__server__export('/data') }

      it do
        is_expected.to contain_nfs__client__mount('/net/self/data').with(
          share: 'data',
          server: facts[:networking]['fqdn'],
          atboot: true
        )
      end
    end
  end # on os
end # on_supported_os

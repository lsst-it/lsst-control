# frozen_string_literal: true

require 'spec_helper'

describe 'comcam-dc01.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
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
          role: 'ccs-dc',
          site: 'tu',
          cluster: 'comcam-ccs',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_s3daemon__instance('tu-comcam').with(
          image: 'ghcr.io/lsst-dm/s3daemon:sha-57e1aa9',
          volumes: [
            '/data:/data',
            '/home:/home',
          ],
          env: {
            'S3_ENDPOINT_URL' => 'https://s3.tu.lsst.org',
            'S3DAEMON_PORT' => 15_570,
          }
        )
      end

      it do
        is_expected.to contain_s3daemon__instance('tu-comcam-s3nd').with(
          image: 'ghcr.io/lsst-dm/s3nd:1.1.0',
          volumes: [
            '/data:/data',
            '/home:/home',
          ],
          env: {
            'S3ND_ENDPOINT_URL' => 'https://s3.tu.lsst.org',
            'S3ND_PORT' => 15_571,
          }
        )
      end

      it do
        is_expected.to contain_s3daemon__instance('s3dfrgw-comcam').with(
          image: 'ghcr.io/lsst-dm/s3daemon:sha-57e1aa9',
          volumes: [
            '/data:/data',
            '/home:/home',
          ],
          env: {
            'S3_ENDPOINT_URL' => 'https://s3dfrgw.slac.stanford.edu',
            'S3DAEMON_PORT' => 15_580,
          }
        )
      end

      it do
        is_expected.to contain_s3daemon__instance('s3dfrgw-comcam-s3nd').with(
          image: 'ghcr.io/lsst-dm/s3nd:1.1.0',
          volumes: [
            '/data:/data',
            '/home:/home',
          ],
          env: {
            'S3ND_ENDPOINT_URL' => 'https://s3dfrgw.slac.stanford.edu',
            'S3ND_PORT' => 15_581,
          }
        )
      end

      include_examples 'baremetal'
      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(3) }

      context 'with ens2f0' do
        let(:interface) { 'ens2f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with ens2f1' do
        let(:interface) { 'ens2f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm bridge slave interface', master: 'lsst-daq'
        it { expect(nm_keyfile['ethtool']['ring-rx']).to eq(4096) }
        it { expect(nm_keyfile['ethtool']['ring-tx']).to eq(4096) }
      end

      context 'with lsst-daq' do
        let(:interface) { 'lsst-daq' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm bridge interface'
        it { expect(nm_keyfile['ipv4']['ignore-auto-dns']).to be true }
      end
    end # on os
  end # on_supported_os
end

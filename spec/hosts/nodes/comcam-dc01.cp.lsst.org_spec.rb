# frozen_string_literal: true

require 'spec_helper'

describe 'comcam-dc01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'PowerEdge R6515',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'ccs-dc',
          cluster: 'comcam-ccs',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_s3daemon__instance('cp-comcam').with(
          image: 'ghcr.io/lsst-dm/s3daemon:sha-57e1aa9',
          env: {
            'S3_ENDPOINT_URL' => 'https://s3.cp.lsst.org',
            'S3DAEMON_PORT' => 15_570,
          }
        )
      end

      it do
        is_expected.to contain_s3daemon__instance('cp-comcam-s3nd').with(
          image: 'ghcr.io/lsst-dm/s3nd:sha-1a94702',
          env: {
            'S3ND_ENDPOINT_URL' => 'https://s3.cp.lsst.org',
            'S3ND_PORT' => 15_571,
          }
        )
      end

      it do
        is_expected.to contain_s3daemon__instance('sdfembs3-comcam').with(
          image: 'ghcr.io/lsst-dm/s3daemon:sha-57e1aa9',
          env: {
            'S3_ENDPOINT_URL' => 'https://sdfembs3.sdf.slac.stanford.edu',
            'S3DAEMON_PORT' => 15_580,
          }
        )
      end

      it do
        is_expected.to contain_s3daemon__instance('sdfembs3-comcam-s3nd').with(
          image: 'ghcr.io/lsst-dm/s3nd:sha-1a94702',
          env: {
            'S3ND_ENDPOINT_URL' => 'https://sdfembs3.sdf.slac.stanford.edu',
            'S3ND_PORT' => 15_581,
          }
        )
      end

      include_examples 'baremetal'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(7) }

      %w[
        ens1f1np1
        eno1
        eno2
        ens3f1np1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with ens1f0np0' do
        let(:interface) { 'ens1f0np0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with ens3f0np0' do
        let(:interface) { 'ens3f0np0' }

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
      end
    end
  end # on os
end # on_supported_os

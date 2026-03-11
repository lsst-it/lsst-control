# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-dc1.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
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
          role: 'ccs-dc',
          cluster: 'auxtel-ccs',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(1) }

      context 'with ens192' do
        let(:interface) { 'ens192' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      it do
        is_expected.to contain_nfs__client__mount('/data').with(
          share: 'data',
          server: 'auxtel-fp01.cp.lsst.org',
          atboot: true,
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/repo').with(
          share: 'auxtel/repo',
          server: 'nfs-auxtel.cp.lsst.org',
          atboot: true,
        )
      end
    end
  end # on os
end # on_supported_os

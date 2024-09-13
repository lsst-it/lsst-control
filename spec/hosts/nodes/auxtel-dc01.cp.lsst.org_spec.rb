# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-dc01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
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
          role: 'atsccs',
          site: 'cp',
          cluster: 'auxtel-ccs',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'

      it do
        is_expected.to contain_nfs__client__mount('/data').with(
          share: 'data',
          server: 'auxtel-fp01.cp.lsst.org',
          atboot: true
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/repo').with(
          share: 'auxtel/repo',
          server: 'nfs-auxtel.cp.lsst.org',
          atboot: true
        )
      end
    end # on os
  end # on_supported_os
end # role

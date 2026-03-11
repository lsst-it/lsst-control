# frozen_string_literal: true

require 'spec_helper'

describe 'nfs3.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
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
          role: 'nfsserver',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it_behaves_like 'baremetal'
      include_context 'with nm interface'

      it do
        is_expected.to contain_nfs__client__mount('/net/self/comcam').with(
          share: 'comcam',
          server: facts[:networking]['fqdn'],
          atboot: true,
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/net/self/lsstcam').with(
          share: 'lsstcam',
          server: facts[:networking]['fqdn'],
          atboot: true,
        )
      end
    end # on os
  end # on_supported_os
end

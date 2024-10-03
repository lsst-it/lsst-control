# frozen_string_literal: true

require 'spec_helper'

describe 'rucio01.ls.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'vmware',
                            dmi: {
                              'product' => {
                                'name' => 'VMware7,1',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'rucio',
          site: 'ls',
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

      it { is_expected.to contain_class('nfs').with_client_enabled(true) }

      it do
        is_expected.to contain_nfs__client__mount('/repo/LATISS').with(
          share: '/auxtel/repo/LATISS',
          server: 'nfs-auxtel.ls.lsst.org',
          atboot: true
        )
      end

      it do
        is_expected.to contain_nfs__client__mount('/datasets').with(
          share: '/lsstdata',
          server: 'nfs-lsstdata.ls.lsst.org',
          atboot: true
        )
      end
    end
  end # on os
end # on_supported_os

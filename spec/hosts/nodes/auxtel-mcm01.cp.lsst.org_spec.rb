# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-mcm01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: true,
                            virtual: 'vmware',
                            dmi: {
                              'product' => {
                                'name' => 'VMware7,1',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'ccs-mcm',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(2) }

      context 'with ens192' do
        let(:interface) { 'ens192' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm dhcp interface'
      end

      context 'with ens224' do
        let(:interface) { 'ens224' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['never-default']).to be(true) }

        it_behaves_like 'nm dhcp interface'
      end
    end # on os
  end # on_supported_os
end

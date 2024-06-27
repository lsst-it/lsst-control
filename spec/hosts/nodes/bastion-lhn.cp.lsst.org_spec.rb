# frozen_string_literal: true

require 'spec_helper'

describe 'bastion-lhn.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'bastion-lhn.cp.lsst.org',
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
          role: 'generic',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(1) }

      context 'with ens192' do
        let(:interface) { 'ens192' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm manual interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.164.253/24,139.229.164.254') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.160.53;139.229.160.54;139.229.160.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('cp.lsst.org;') }
      end
    end # on os
  end # on_supported_os
end

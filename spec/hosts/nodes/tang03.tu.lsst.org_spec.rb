# frozen_string_literal: true

require 'spec_helper'

describe 'tang03.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'tang03.tu.lsst.org',
                       is_virtual: true,
                       virtual: 'kvm',
                       dmi: {
                         'product' => {
                           'name' => 'KVM',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'tang',
          site: 'tu',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'vm'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(1) }

      context 'with enp1s0' do
        let(:interface) { 'enp1s0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm manual interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('140.252.146.89/27,140.252.146.65') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('140.252.146.71;140.252.146.72;140.252.146.73;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('tu.lsst.org;') }
      end
    end # on os
  end # on_supported_os
end

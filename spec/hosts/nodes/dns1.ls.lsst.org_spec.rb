# frozen_string_literal: true

require 'spec_helper'

describe 'dns1.ls.lsst.org', :site do
  on_supported_os.each do |os, facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) { facts.merge(fqdn: 'dns1.ls.lsst.org') }
      let(:node_params) do
        {
          role: 'dnscache',
          site: 'ls',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_context 'with nm interface'
      it { is_expected.to have_network__interface_resource_count(0) }
      it { is_expected.to have_profile__nm__connection_resource_count(1) }

      context 'with ens3' do
        let(:interface) { 'ens3' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['ipv4']['address1']).to eq('139.229.135.53/24,139.229.135.254') }
        it { expect(nm_keyfile['ipv4']['dns']).to eq('139.229.135.53;139.229.135.54;139.229.135.55;') }
        it { expect(nm_keyfile['ipv4']['dns-search']).to eq('ls.lsst.org;') }
        it { expect(nm_keyfile['ipv4']['method']).to eq('manual') }
      end
    end # on os
  end # on_supported_os
end

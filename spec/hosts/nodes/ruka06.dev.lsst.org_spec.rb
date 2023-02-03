# frozen_string_literal: true

require 'spec_helper'
require 'iniparse'

shared_examples 'named interface' do
  it { expect(ini['connection']['id']).to eq(interface) }
  it { expect(ini['connection']['interface-name']).to eq(interface) }
end

shared_examples 'disabled interface' do
  it_behaves_like 'named interface'
  it { expect(ini['connection']['id']).to eq(interface) }
  it { expect(ini['connection']['interface-name']).to eq(interface) }
  it { expect(ini['connection']['type']).to eq('ethernet') }
  it { expect(ini['connection']['autoconnect']).to be false }
  it { expect(ini['ipv4']['method']).to eq('ignore') }
  it { expect(ini['ipv6']['method']).to eq('ignore') }
end

#
# Testing network interfaces from the site/dev/role/hypervisor/major/** layers.
#
describe 'ruka06.dev.lsst.org', :site do
  alma9 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '9' }).first
  # rubocop:disable Naming/VariableNumber
  { 'almalinux-9-x86_64': alma9 }.each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) do
        override_facts(facts, fqdn: 'ruka06.dev.lsst.org')
      end
      let(:ini) do
        IniParse.parse(catalogue.resource('profile::nm::connection', interface)[:content])
      end

      let(:node_params) do
        {
          role: 'hypervisor',
          site: 'dev',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to have_profile__nm__connection_resource_count(7) }

      %w[
        eno1
        eno2
        eno3
        eno4
        enp10s0f1
      ].each do |i|
        context "with #{name}" do
          let(:interface) { i }

          it_behaves_like 'disabled interface'
        end
      end

      context 'with enp10s0f0' do
        let(:interface) { 'enp10s0f0' }

        it_behaves_like 'named interface'
        it { expect(ini['connection']['type']).to eq('ethernet') }
        it { expect(ini['connection']['autoconnect']).to be_nil }
        it { expect(ini['connection']['master']).to eq('br2101') }
        it { expect(ini['connection']['slave-type']).to eq('bridge') }
      end

      context 'with br2101' do
        let(:interface) { 'br2101' }

        it_behaves_like 'named interface'
        it { expect(ini['connection']['type']).to eq('bridge') }
        it { expect(ini['connection']['autoconnect']).to be_nil }
        it { expect(ini['bridge']['stp']).to be false }
        it { expect(ini['ipv4']['method']).to eq('auto') }
        it { expect(ini['ipv6']['method']).to eq('disabled') }
      end
    end # on os
  end # on_supported_os
end

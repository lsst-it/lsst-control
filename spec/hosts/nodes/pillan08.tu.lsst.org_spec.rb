# frozen_string_literal: true

require 'spec_helper'

#
# pillan08 is "special" and has different PCI bus addresses for the X550T NIC.
#
describe 'pillan08.tu.lsst.org', :site do
  alma9 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '9' }).first
  # rubocop:disable Naming/VariableNumber
  { 'almalinux-9-x86_64': alma9 }.each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) { override_facts(facts, fqdn: 'pillan08.tu.lsst.org') }
      let(:node_params) do
        {
          role: 'rke',
          site: 'tu',
          cluster: 'pillan',
        }
      end

      include_context 'with nm interface'

      it { is_expected.to compile.with_all_deps }

      # 2 extra instances in the catalog for the rename interfaces
      it { is_expected.to have_profile__nm__connection_resource_count(12 + 2) }

      %w[
        enp4s0f3u2u2c2
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      %w[
        eno1np0
        eno2np1
        enp197s0f0
        enp197s0f1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm named interface'
          it_behaves_like 'nm ethernet interface'
          it { expect(nm_keyfile['connection']['autoconnect']).to be_nil }
          it { expect(nm_keyfile['connection']['master']).to eq('bond0') }
          it { expect(nm_keyfile['connection']['slave-type']).to eq('bond') }
        end
      end

      context 'with bond0' do
        let(:interface) { 'bond0' }

        it_behaves_like 'nm named interface'
        it { expect(nm_keyfile['bond']['mode']).to eq('802.3ad') }
        # XXX add more tests
      end

      Hash[*%w[
        bond0.3065 br3065
        bond0.3075 br3075
        bond0.3085 br3085
      ]].each do |slave, master|
        context "with #{slave}" do
          let(:interface) { slave }

          it_behaves_like 'nm named interface'
          it_behaves_like 'nm bridge slave interface', master: master
        end
      end

      %w[
        br3065
        br3065
        br3085
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm named interface'
          it_behaves_like 'nm bridge interface'
          it_behaves_like 'nm no-ip interface'
        end
      end
    end # on os
  end # on_supported_os
end

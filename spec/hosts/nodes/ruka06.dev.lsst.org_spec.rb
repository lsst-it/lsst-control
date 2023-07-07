# frozen_string_literal: true

require 'spec_helper'

#
# Testing network interfaces from the site/dev/role/hypervisor/major/** layers.
#
describe 'ruka06.dev.lsst.org', :sitepp do
  alma9 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '9' }).first
  # rubocop:disable Naming/VariableNumber
  { 'almalinux-9-x86_64': alma9 }.each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) do
        override_facts(facts,
                       fqdn: 'ruka06.dev.lsst.org',
                       is_virtual: false,
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R430',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'hypervisor',
          site: 'dev',
          variant: 'r430',
          subvariant: 'hypervisor',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(7) }

      %w[
        eno1
        eno2
        eno3
        eno4
        enp10s0f1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with enp10s0f0' do
        let(:interface) { 'enp10s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm bridge slave interface', master: 'br2101'
      end

      context 'with br2101' do
        let(:interface) { 'br2101' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm bridge interface'
      end
    end # on os
  end # on_supported_os
end

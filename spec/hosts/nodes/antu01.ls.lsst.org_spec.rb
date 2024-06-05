# frozen_string_literal: true

require 'spec_helper'

describe 'antu01.ls.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'antu01.ls.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'AS -1115HS-TNR',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'rke',
          site: 'ls',
          cluster: 'antu',
          variant: '1115s',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'
      include_examples 'docker', docker_version: '24.0.9'

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'antu' => {
              'group' => 'antu',
              'member' => 'antu[01-04]',
            },
          },
        )
      end

      it do
        is_expected.to contain_class('rke').with(
          version: '1.5.9',
        )
      end

      it { is_expected.to have_nm__connection_resource_count(5) }

      %w[
        enp12s0f4u1u2c2
        enp65s0f0
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with enp65s0f1' do
        let(:interface) { 'enp65s0f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with enp65s0f0.2130' do
        let(:interface) { 'enp65s0f0.2130' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 2130, parent: 'enp65s0f0'
        it_behaves_like 'nm bridge slave interface', master: 'br2130'
      end

      context 'with br2130' do
        let(:interface) { 'br2130' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm no-ip interface'
        it_behaves_like 'nm bridge interface'
      end
    end # on os
  end # on_supported_os
end

# frozen_string_literal: true

require 'spec_helper'

describe 'kueyen01.dev.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'kueyen01.dev.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R440',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'rke',
          site: 'dev',
          cluster: 'kueyen',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'docker', docker_version: '24.0.9'
      include_examples 'baremetal'
      include_context 'with nm interface'

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'kueyen' => {
              'group' => 'kueyen',
              'member' => 'kueyen[01-03]',
            },
          },
        )
      end

      it do
        is_expected.to contain_class('rke').with(
          version: '1.5.12',
        )
      end

      it do
        is_expected.to contain_class('cni::plugins').with(
          version: '1.2.0',
          checksum: 'f3a841324845ca6bf0d4091b4fc7f97e18a623172158b72fc3fdcdb9d42d2d37',
          enable: ['macvlan'],
        )
      end

      it { is_expected.to contain_class('cni::plugins::dhcp') }

      it { is_expected.to contain_class('profile::core::ospl').with_enable_rundir(true) }

      it { is_expected.to have_nm__connection_resource_count(6) }

      %w[
        em1
        em2
        ens2f0
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with ens2f1' do
        let(:interface) { 'ens2f1' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      context 'with ens2f0.2301' do
        let(:interface) { 'ens2f0.2301' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm vlan interface', id: 2301, parent: 'ens2f0'
        it_behaves_like 'nm bridge slave interface', master: 'br2301'
      end

      context 'with br2301' do
        let(:interface) { 'br2301' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm bridge interface'
      end
    end # on os
  end # on_supported_os
end

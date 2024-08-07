# frozen_string_literal: true

require 'spec_helper'

describe 'elqui01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'elqui01.tu.lsst.org',
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
          role: 'rke2',
          cluster: 'elqui',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_context 'with nm interface'

      it do
        expect(catalogue.resource('class', 'rke2')[:config]).to include(
          'node-label' => ['role=storage-node'],
        )
      end

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'elqui' => {
              'group' => 'elqui',
              'member' => 'elqui[01-18]',
            },
          },
        )
      end

      it do
        is_expected.to contain_class('rke2')
      end

      it do
        expect(catalogue.resource('class', 'nm')[:conf]).to include(
          'device' => {
            'keep-configuration' => 'no',
            'allowed-connections' => 'except:origin:nm-initrd-generator',
          },
        )
      end

      it { is_expected.to have_nm__connection_resource_count(5 + 3) }

      %w[
        enp13s0f4u1u2c2
        enp65s0f0
        enp65s0f1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      %w[
        enp1s0f0np0
        enp1s0f1np1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm enabled interface'
          it_behaves_like 'nm ethernet interface'
          it_behaves_like 'nm bond slave interface', master: 'bond0'
        end
      end

      context 'with bond0' do
        let(:interface) { 'bond0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm bond interface'
        it_behaves_like 'nm no-ip interface'
      end

      Hash[*%w[
        bond0.1801 br1801
      ]].each do |slave, master|
        context "with #{slave}" do
          let(:interface) { slave }

          it_behaves_like 'nm enabled interface'
          it_behaves_like 'nm bridge slave interface', master: master
        end
      end

      %w[
        br1801
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm enabled interface'
          it_behaves_like 'nm bridge interface'
          it_behaves_like 'nm dhcp interface'
        end
      end
    end # on os
  end # on_supported_os
end

# frozen_string_literal: true

require 'spec_helper'

describe 'pillan01.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'pillan01.tu.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'AS -1114S-WN10RT',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'rke',
          site: 'tu',
          cluster: 'pillan',
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
        is_expected.to contain_class('profile::core::rke').with(
          version: '1.5.10',
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

      it { is_expected.to have_nm__connection_resource_count(14) }

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
        enp129s0f0
        enp129s0f1
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
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm bond interface'
      end

      Hash[*%w[
        bond0.3035 br3035
        bond0.3065 br3065
        bond0.3075 br3075
        bond0.3085 br3085
      ]].each do |slave, master|
        context "with #{slave}" do
          let(:interface) { slave }

          it_behaves_like 'nm enabled interface'
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

          it_behaves_like 'nm enabled interface'
          it_behaves_like 'nm bridge interface'
          it_behaves_like 'nm no-ip interface'
        end
      end

      context 'with br3035' do
        let(:interface) { 'br3035' }
        let(:vlan) { '3035' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm no-ip interface'
        it_behaves_like 'nm bridge interface'
        it { expect(nm_keyfile['ipv4']['route1']).to eq('140.252.147.192/27') }
        it { expect(nm_keyfile['ipv4']['route1_options']).to eq("table=#{vlan}") }
        it { expect(nm_keyfile['ipv4']['route2']).to eq('0.0.0.0/0,140.252.147.193') }
        it { expect(nm_keyfile['ipv4']['route2_options']).to eq("table=#{vlan}") }
        it { expect(nm_keyfile['ipv4']['routing-rule1']).to eq("priority 100 from 140.252.147.192/27 table #{vlan}") }
      end
    end # on os
  end # on_supported_os
end

# frozen_string_literal: true

require 'spec_helper'

describe 'ayekan01.ls.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) { override_facts(os_facts, fqdn: 'ayekan01.ls.lsst.org') }
      let(:node_params) do
        {
          role: 'rke',
          site: 'ls',
          cluster: 'ayekan',
        }
      end

      include_context 'with nm interface'

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_class('profile::core::sysctl::rp_filter').with_enable(false)
      end

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'ayekan' => {
              'group' => 'ayekan',
              'member' => 'ayekan[01-03]',
            },
          },
        )
      end

      it do
        is_expected.to contain_class('rke').with(
          version: '1.4.6',
          checksum: '12d8fee6f759eac64b3981ef2822353993328f2f839ac88b3739bfec0b9d818c',
        )
      end

      it { is_expected.to have_nm__connection_resource_count(5) }

      %w[
        eno1np0
        eno2np1
        enp4s0f3u2u2c2
        enp129s0f1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with enp129s0f0' do
        let(:interface) { 'enp129s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end
    end # on os
  end # on_supported_os
end

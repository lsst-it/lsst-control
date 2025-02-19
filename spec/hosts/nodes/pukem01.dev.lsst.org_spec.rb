# frozen_string_literal: true
require 'spec_helper'
describe 'pukem01.dev.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}
    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'pukem01.dev.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge C6420',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'rke2server',
          cluster: 'pukem',
          site: 'dev',
        }
      end
      it { is_expected.to compile.with_all_deps }
      include_examples 'baremetal'
      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(1) }
      context 'with ens4f0' do
        let(:interface) { 'ens4f0' }
        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end

      it do
        expect(catalogue.resource('class', 'rke2')[:config]).to include(
          'node-label' => ['role=storage-node']
        )
      end

      it do
        is_expected.to contain_class('rke2').with(
          node_type: 'server',
          release_series: '1.30',
          version: '1.30.7~rke2r1'
        )
      end
    end # on os
  end # on_supported_os
end

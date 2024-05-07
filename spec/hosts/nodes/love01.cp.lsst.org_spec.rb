# frozen_string_literal: true

require 'spec_helper'

describe 'love01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'love01.cp.lsst.org',
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
          role: 'amor',
          cluster: 'amor',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'

      it do
        is_expected.to contain_class('docker::networks').with(
          'networks' => {
            'dds-network' => {
              'ensure' => 'present',
              'driver' => 'macvlan',
              'subnet' => '139.229.170.0/24',
              'gateway' => '139.229.170.254',
              'options' => ['parent=ens2f0'],
            },
          },
        )
      end
    end # on os
  end # on_supported_os
end

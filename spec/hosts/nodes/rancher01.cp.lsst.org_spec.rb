# frozen_string_literal: true

require 'spec_helper'

describe 'rancher01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: true,
                            virtual: 'kvm',
                            dmi: {
                              'product' => {
                                'name' => 'KVM',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'rke2server',
          site: 'cp',
          cluster: 'rancher',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_class('rke2').with(
          node_type: 'server',
          release_series: '1.32',
          version: '1.32.9~rke2r1'
        )
      end

      include_examples 'vm'
      it { is_expected.to have_nm__connection_resource_count(0) }
    end # on os
  end # on_supported_os
end

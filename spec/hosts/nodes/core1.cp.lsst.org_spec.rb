# frozen_string_literal: true

require 'spec_helper'

describe 'core1.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    # XXX networking needs to be updated to support EL8+
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'core1.cp.lsst.org',
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
          role: 'hypervisor',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples('baremetal',
                       bmc: {
                         lan1: {
                           ip: '10.18.3.10',
                           netmask: '255.255.255.0',
                           gateway: '10.18.3.254',
                           type: 'static',
                         },
                       })

      it do
        is_expected.to contain_network__interface('em1').with(
          ipaddress: '139.229.160.1',
        )
      end
    end # on os
  end # on_supported_os
end # role

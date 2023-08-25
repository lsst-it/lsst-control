# frozen_string_literal: true

require 'spec_helper'

describe 'core3.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    # XXX networking needs to be updated to support EL8+
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(facts,
                       fqdn: 'core3.tu.lsst.org',
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
          site: 'tu',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples('baremetal',
                       bmc: {
                         lan1: {
                           ip: '140.252.146.140',
                           netmask: '255.255.255.192',
                           gateway: '140.252.146.129',
                           type: 'static',
                         },
                       })

      it do
        is_expected.to contain_network__interface('em1').with(
          ipaddress: '140.252.146.70',
        )
      end
    end # on os
  end # on_supported_os
end # role

# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-fb01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    # XXX networking needs to be updated to support EL8+
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'lsstcam-fb01.cp.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'EPMe-42',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'ccs-hcu',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal no bmc'

      it do
        is_expected.to contain_network__interface('enp3s0').with(
          ipaddress: '139.229.175.89',
          gateway: '139.229.175.126',
          netmask: '255.255.255.192',
          nozeroconf: 'yes',
          onboot: 'yes',
          type: 'Ethernet',
        )
      end
    end # on os
  end # on_supported_os
end # role

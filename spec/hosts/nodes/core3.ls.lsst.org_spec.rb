# frozen_string_literal: true

require 'spec_helper'

describe 'core3.ls.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    # XXX networking needs to be updated to support EL8+
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'core3.ls.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'hypervisor',
          site: 'ls',
        }
      end

      it do
        is_expected.to contain_network__interface('em1').with(
          ipaddress: '139.229.135.4',
        )
      end
    end # on os
  end # on_supported_os
end # role

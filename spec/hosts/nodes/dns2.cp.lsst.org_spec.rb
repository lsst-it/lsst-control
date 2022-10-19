# frozen_string_literal: true

require 'spec_helper'

describe 'dns2.cp.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:primary) { 'ens192' }

      let(:facts) do
        facts[:networking]['primary'] = primary
        facts.merge(
          fqdn: 'dns2.cp.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'dnscache',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_network__interface(primary).with(
          ipaddress: '139.229.160.54',
          gateway: '139.229.160.254',
          netmask: '255.255.255.0',
        )
      end

      it do
        is_expected.to contain_network__interface('ens32').with(
          ipaddress: '192.168.251.241',
          netmask: '255.255.255.0',
          gateway: '192.168.251.1',
        )
      end
    end # on os
  end # on_supported_os
end

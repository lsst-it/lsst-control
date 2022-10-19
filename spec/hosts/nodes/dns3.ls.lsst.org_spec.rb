# frozen_string_literal: true

require 'spec_helper'

describe 'dns3.ls.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:primary) do
        if (facts[:os]['family'] == 'RedHat') && (facts[:os]['release']['major'] == '7')
          'eth0'
        else
          'ens192'
        end
      end

      let(:facts) do
        facts[:networking]['primary'] = primary
        facts.merge(
          fqdn: 'dns3.ls.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'dnscache',
          site: 'ls',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_network__interface(primary).with(
          ipaddress: '139.229.135.55',
          gateway: '139.229.135.254',
          netmask: '255.255.255.0',
        )
      end
    end # on os
  end # on_supported_os
end

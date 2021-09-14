# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic daq manager' do
  it { is_expected.to contain_class('profile::core::common') }
  it { is_expected.to contain_class('hosts') }
  it { is_expected.to contain_class('nfs') }

  it do
    is_expected.to contain_class('dhcp').with(
      interfaces: ['lsst-daq'],
    )
  end

  it do
    is_expected.to contain_class('chrony').with(
      port: 123,
      queryhosts: ['192.168/16'],
    )
  end
end

shared_examples 'lsst-daq dhcp-server' do
  it do
    is_expected.to contain_network__interface('lsst-daq').with(
      bootproto: 'none',
      defroute: 'no',
      ipaddress: '192.168.100.1',
      ipv6init: 'no',
      netmask: '255.255.255.0',
      onboot: true,
      type: 'Ethernet',
    )
  end
end

describe 'daq-mgt role', :site do
  let(:node_params) do
    {
      org: 'lsst',
      role: 'daq-mgt',
      ipa_force_join: false, # easy_ipa
    }
  end

  lsst_sites.each do |site|
    context "with site #{site}" do
      let(:node_params) do
        super().merge(
          site: site,
        )
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'generic daq manager'
    end
  end # site

  context 'when host atsdaq-mgmt.cp.lsst.org', :site do
    let(:facts) { { fqdn: 'atsdaq-mgmt.cp.lsst.org' } }
    let(:node_params) do
      super().merge(
        site: 'cp',
      )
    end

    include_examples 'generic daq manager'
    include_examples 'lsst-daq dhcp-server'

    it do
      is_expected.to contain_network__interface('p3p1').with(
        ensure: 'absent',
      )
    end


    it do
      is_expected.to contain_class('hosts').with(
        host_entries: {
          'auxtel-sm' => {
            'ip' => '192.168.101.2',
          },
        },
      )
    end
  end
end

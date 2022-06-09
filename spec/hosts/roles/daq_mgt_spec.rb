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

  it do
    is_expected.to contain_accounts__user('rce').with(
      uid: '62002',
      gid: '62002',
      shell: '/sbin/nologin',
    )
  end

  it do
    is_expected.to contain_accounts__user('dsid').with(
      uid: '62003',
      gid: '62003',
      shell: '/sbin/nologin',
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

  # XXX is it wrong to tie role and host specific details together?  This may
  # cause grief when refactoring in the future but it is also the only way to
  # fully test features when depend upon host specific data.  An alternative
  # would be to construct an alternate hiera hierarchy for testing each role
  # with synthetic node data.
  context 'when host auxtel-daq-mgt.cp.lsst.org', :site do
    let(:facts) { { fqdn: 'auxtel-daq-mgt.cp.lsst.org' } }
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

  context 'when host daq-mgt.tu.lsst.org', :site do
    let(:facts) { { fqdn: 'daq-mgt.tu.lsst.org' } }
    let(:node_params) do
      super().merge(
        site: 'tu',
      )
    end

    include_examples 'generic daq manager'
    include_examples 'lsst-daq dhcp-server'

    it do
      is_expected.to contain_network__interface('p2p1').with(
        ensure: 'absent',
      )
    end

    it do
      is_expected.to contain_network__interface('em2').with(
        bootproto: 'none',
        defroute: 'no',
        ipaddress: '10.0.0.1',
        ipv6init: 'no',
        netmask: '255.255.255.0',
        onboot: 'yes',
        type: 'Ethernet',
      )
    end
  end
end

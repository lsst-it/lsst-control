# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic daq manager' do |facts:|
  include_examples 'common', facts: facts, chrony: false
  include_examples 'lsst-daq dhcp-server'
  include_examples 'lsst-daq sysctls'
  include_examples 'nfsv2 enabled', facts: facts
  include_examples 'daq common'
  include_examples 'daq nfs exports'

  it { is_expected.to contain_class('hosts') }

  it do
    is_expected.to contain_class('dhcp').with(
      dnsdomain: [],
      interfaces: ['lsst-daq'],
      nameservers: [],
      ntpservers: [],
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

shared_examples 'daq nfs exports' do
  it do
    is_expected.to contain_class('nfs').with(
      server_enabled: true,
      client_enabled: true,
      nfs_v4_client: false,
    )
  end

  it { is_expected.to contain_class('nfs::server').with_nfs_v4(false) }
  it { is_expected.to contain_nfs__server__export('/srv/nfs/dsl') }
  it { is_expected.to contain_nfs__server__export('/srv/nfs/lsst-daq') }

  it do
    is_expected.to contain_nfs__client__mount('/net/self/dsl').with(
      share: '/srv/nfs/dsl',
      server: facts[:fqdn],
      atboot: true,
    )
  end

  it do
    is_expected.to contain_nfs__client__mount('/net/self/lsst-daq').with(
      share: '/srv/nfs/lsst-daq',
      server: facts[:fqdn],
      atboot: true,
    )
  end
end

# XXX is it wrong to tie role and host specific details together?  This may
# cause grief when refactoring in the future but it is also the only way to
# fully test features when depend upon host specific data.  An alternative
# would be to construct an alternate hiera hierarchy for testing each role
# with synthetic node data.

role = 'daq-mgt'

describe "#{role} role" do
  on_supported_os.each do |os, facts|
    # XXX networking needs to be updated to support EL8+
    next unless os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: self.class.description,
        )
      end

      let(:node_params) do
        {
          role: role,
          site: site,
        }
      end

      describe 'auxtel-daq-mgt.cp.lsst.org', :site do
        let(:site) { 'cp' }

        it { is_expected.to compile.with_all_deps }

        include_examples 'generic daq manager', facts: facts

        it { is_expected.to contain_class('daq::daqsdk').with_version('R5-V5.0') }
        it { is_expected.to contain_class('daq::rptsdk').with_version('V3.5.3') }
        it { is_expected.to contain_network__interface('p3p1').with_ensure('absent') }

        it do
          is_expected.to contain_class('hosts').with(
            host_entries: {
              'auxtel-sm' => {
                'ip' => '192.168.101.2',
              },
            },
          )
        end

        it do
          is_expected.to contain_network__interface('em2').with(
            bootproto: 'none',
            # defroute: 'no',
            ipaddress: '192.168.101.1',
            # ipv6init: 'no',
            netmask: '255.255.255.0',
            onboot: 'yes',
            type: 'Ethernet',
          )
        end
      end

      describe 'daq-mgt.tu.lsst.org', :site do
        let(:site) { 'tu' }

        include_examples 'generic daq manager', facts: facts

        it { is_expected.to contain_class('daq::daqsdk').with_version('R5-V5.0') }
        it { is_expected.to contain_class('daq::rptsdk').with_version('V3.5.3') }
        it { is_expected.to contain_network__interface('p2p1').with_ensure('absent') }

        it do
          is_expected.to contain_class('hosts').with(
            host_entries: {
              'tts-sm' => {
                'ip' => '10.0.0.212',
              },
            },
          )
        end

        it do
          is_expected.to contain_network__interface('em4').with(
            bootproto: 'none',
            # defroute: 'no',
            ipaddress: '10.0.0.1',
            # ipv6init: 'no',
            netmask: '255.255.255.0',
            onboot: 'yes',
            type: 'Ethernet',
          )
        end
      end

      describe 'comcam-daq-mgt.cp.lsst.org', :site do
        let(:site) { 'cp' }

        include_examples 'generic daq manager', facts: facts

        it { is_expected.to contain_class('daq::daqsdk').with_version('R5-V5.0') }
        it { is_expected.to contain_class('daq::rptsdk').with_version('V3.5.3') }
        it { is_expected.to contain_network__interface('p2p1').with_ensure('absent') }

        it do
          is_expected.to contain_class('hosts').with(
            host_entries: {
              'comcam-sm' => {
                'ip' => '10.0.0.212',
              },
            },
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
    end # on os
  end # on_supported_os
end # role

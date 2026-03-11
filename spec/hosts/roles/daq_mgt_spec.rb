# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic daq manager' do |os_facts:, site:|
  it_behaves_like 'common', os_facts:, site:, chrony: false
  it_behaves_like 'lsst-daq sysctls'
  it_behaves_like('nfsv2 enabled', os_facts:)
  it_behaves_like 'daq common'

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

role = 'daq-mgt'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :sitepp do
          let(:node_params) do
            {
              role:,
              site:,
            }
          end
          let(:facts) { lsst_override_facts(os_facts) }

          it { is_expected.to compile.with_all_deps }

          it_behaves_like 'generic daq manager', os_facts:, site:
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role

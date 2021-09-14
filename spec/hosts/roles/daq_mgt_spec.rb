# frozen_string_literal: true

require 'spec_helper'

describe 'test1.dev.lsst.org', :site do
  describe 'daq-mgt role' do
    lsst_sites.each do |site|
      context "with site #{site}" do
        let(:node_params) do
          {
            org: 'lsst',
            site: site,
            role: 'daq-mgt',
            ipa_force_join: false, # easy_ipa
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('profile::core::common') }

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

        it { is_expected.to contain_class('profile::ccs::daq_interface') }

        #it do
        #  is_expected.to contain_network__interface('lsst-daq').with(
        #    bootproto: 'none',
        #    ipaddress: '192.168.100.1',
        #    netmask: '255.255.255.0',
        #  )
        #end

        it { is_expected.to contain_class('hosts') }
      end
    end  # site
  end  # role
end

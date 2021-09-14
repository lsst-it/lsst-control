# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic daq manager' do
  it { is_expected.to compile.with_all_deps }

  it { is_expected.to contain_class('profile::core::common') }
  it { is_expected.to contain_class('profile::ccs::daq_interface') }
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

        include_examples 'generic daq manager'

      end
    end  # site
  end  # role
end

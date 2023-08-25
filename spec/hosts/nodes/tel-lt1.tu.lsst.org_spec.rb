# frozen_string_literal: true

require 'spec_helper'

describe 'tel-lt1.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        override_facts(facts,
                       fqdn: 'tel-lt1.tu.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'ZBOX-CI327NANO-GS-01',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'generic',
          site: 'tu',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal no bmc'
      it { is_expected.not_to contain_class('resolv_conf') }

      it do
        is_expected.to contain_k5login('/home/saluser/.k5login').with(
          ensure: 'present',
          principals: ['saluser/tel-hw1.tu.lsst.org@LSST.CLOUD'],
        )
      end
    end # on os
  end # on_supported_os
end # role

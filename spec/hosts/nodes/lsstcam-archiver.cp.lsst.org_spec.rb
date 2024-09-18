# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-archiver.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'AS -1114S-WN10RT',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'nfsclient',
          site: 'cp',
          variant: '1114s',
        }
      end

      it { is_expected.to compile.with_all_deps }

      principals = 1.upto(10).map do |i|
        format('ccs-ipa/lsstcam-dc%02d.cp.lsst.org@LSST.CLOUD', i)
      end

      it do
        is_expected.to contain_k5login('/home/saluser/.k5login').with(
          ensure: 'present',
          principals:
        )
      end
    end # on os
  end # on_supported_os
end # role

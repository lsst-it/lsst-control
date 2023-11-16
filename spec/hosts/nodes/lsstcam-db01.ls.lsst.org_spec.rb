# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-db01.ls.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'lsstcam-db01.ls.lsst.org',
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
          role: 'ccs-database',
          site: 'ls',
          cluster: 'lsstcam-ccs',
          variant: '1114s',
        }
      end
      let(:alert_email) do
        'base-teststand-alerts-aaaai5j4osevcaaobtog67nxlq@lsstc.slack.com'
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'
      include_examples 'ccs alerts'

      it do
        is_expected.to contain_class('ccs_software').with(
          services: {
            'prod' => %w[
              rest-server
              localdb
            ],
          },
        )
      end

      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(5) }

      %w[
        eno1np0
        eno2np1
        enp4s0f3u2u2c2
        enp129s0f1
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with enp129s0f0' do
        let(:interface) { 'enp129s0f0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
      end
    end # on os
  end # on_supported_os
end

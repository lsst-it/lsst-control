# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-db01.ls.lsst.org', :site do
  alma8 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '8' }).first
  # rubocop:disable Naming/VariableNumber
  { 'almalinux-8-x86_64': alma8 }.each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) { facts.merge(fqdn: 'lsstcam-db01.ls.lsst.org') }

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

      it { is_expected.to have_network__interface_resource_count(0) }
      it { is_expected.to have_profile__nm__connection_resource_count(5) }

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

        it_behaves_like 'nm named interface'
        it_behaves_like 'nm dhcp interface'
        it_behaves_like 'nm ethernet interface'
        it { expect(nm_keyfile['connection']['autoconnect']).to be_nil }
      end
    end # on os
  end # on_supported_os
end

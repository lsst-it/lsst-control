# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-mcm.tu.lsst.org', :site do
  centos7 = FacterDB.get_facts({ operatingsystem: 'CentOS', operatingsystemmajrelease: '7' }).first
  # rubocop:disable Naming/VariableNumber
  { 'centos-7-x86_64': centos7 }.each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) { facts.merge(fqdn: 'auxtel-mcm.tu.lsst.org') }
      let(:node_params) do
        {
          role: 'ccs-mcm',
          site: 'tu',
          cluster: 'auxtel-ccs',
        }
      end

      let(:alert_email) do
        'tucson-teststand-aler-aaaae4zsdubhmm3n7mowaugr2y@lsstc.slack.com'
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'ccs alerts'
      include_context 'with nm interface'

      it { is_expected.to contain_package('OpenSpliceDDS') }
      it { is_expected.to contain_file('/etc/ccs/setup-sal5').with_content(%r{^export LSST_DDS_INTERFACE=auxtel-mcm-dds.tu.lsst.org}) }
      it { is_expected.to contain_file('/etc/ccs/setup-sal5').with_content(%r{^export LSST_DDS_PARTITION_PREFIX=tucson}) }
      it { is_expected.to contain_class('Ccs_software::Service') }

      it do
        is_expected.to contain_class('clustershell').with(
          groupmembers: {
            'all' => {
              'group' => 'all',
              'member' => 'auxtel-fp01,auxtel-mcm',
            },
          },
        )
      end
    end # on os
  end # on_supported_os
end # role

# frozen_string_literal: true

require 'spec_helper'

describe 'test1.dev.lsst.org', :site do
  describe 'archiver role' do
    lsst_sites.each do |site|
      context "with site #{site}" do
        let(:node_params) do
          {
            org: 'lsst',
            site: site,
            role: 'archiver',
            ipa_force_join: false, # easy_ipa
          }
        end

        it { is_expected.to compile.with_all_deps }

        include_examples 'lhn sysctls'
        include_examples 'archiver'

        it { is_expected.to contain_rabbitmq_vhost('/test_cc') }
        it { is_expected.to contain_rabbitmq_vhost('/test_at') }
        it { is_expected.to contain_rabbitmq_user_permissions('iip@/test_cc') }
        it { is_expected.to contain_rabbitmq_user_permissions('guest@/test_cc') }
        it { is_expected.to contain_rabbitmq_user_permissions('iip@/test_at') }
        it { is_expected.to contain_rabbitmq_user_permissions('guest@/test_at') }
        it { is_expected.to contain_rabbitmq_exchange('message@/test_cc') }
        it { is_expected.to contain_rabbitmq_exchange('message@/test_at') }

        %w[
          f98_consume@/test_cc
          f99_consume@/test_cc
          cc_foreman_ack_publish@/test_cc
          cc_publish_to_oods@/test_cc
          oods_publish_to_cc@/test_cc
          archive_ctrl_publish@/test_cc
          archive_ctrl_consume@/test_cc
          telemetry_queue@/test_cc

          f98_consume@/test_at
          f99_consume@/test_at
          at_foreman_ack_publish@/test_at
          at_publish_to_oods@/test_at
          oods_publish_to_at@/test_at
          archive_ctrl_publish@/test_at
          archive_ctrl_consume@/test_at
          telemetry_queue@/test_at
        ].each do |q|
          it { is_expected.to contain_rabbitmq_queue(q) }
          it { is_expected.to contain_rabbitmq_binding("message@#{q}") }
        end
      end
    end # site
  end # role
end

# frozen_string_literal: true

require 'spec_helper'

role = 'auxtel-archiver'

describe "#{role} role" do
  on_supported_os.each do |os, facts|
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

      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :site, :common do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'lhn sysctls'
          include_examples 'archiver'

          it { is_expected.to contain_file('/data/repo/LATISS') }

          it { is_expected.to contain_rabbitmq_vhost('/test_at') }
          it { is_expected.to contain_rabbitmq_user_permissions('iip@/test_at') }
          it { is_expected.to contain_rabbitmq_user_permissions('guest@/test_at') }
          it { is_expected.to contain_rabbitmq_exchange('message@/test_at') }

          %w[
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
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role

# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-db01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'lsstcam-db01.cp.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'ccs-database',
          site: 'cp',
          cluster: 'lsstcam-ccs',
        }
      end

      let(:alert_email) do
        'lsstcam-alerts-aaaah4qfu4lhjnjpl4wmbjyx2y@lsstc.slack.com'
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
    end # on os
  end # on_supported_os
end

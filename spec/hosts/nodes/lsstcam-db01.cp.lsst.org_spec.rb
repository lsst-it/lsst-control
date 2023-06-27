# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-db01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        override_facts(facts,
                       fqdn: 'lsstcam-db01.cp.lsst.org',
                       is_virtual: false,
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R640',
                         },
                       })
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
    end # on os
  end # on_supported_os
end

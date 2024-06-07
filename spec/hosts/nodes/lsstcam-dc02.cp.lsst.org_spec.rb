# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-dc02.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'lsstcam-dc02.cp.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'PowerEdge R6515',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'ccs-dc',
          cluster: 'lsstcam-ccs',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal'

      it { is_expected.not_to contain_service('image-handling') }
    end # on os
  end # on_supported_os
end

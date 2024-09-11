# frozen_string_literal: true

require 'spec_helper'

describe 'lsstcam-vw04.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'lsstcam-vw04.cp.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'NUC12WSBi7',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'ccs-desktop',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_context 'with nm interface'
      it { is_expected.to have_nm__connection_resource_count(1) }

      context 'with enp114s0' do
        let(:interface) { 'enp114s0' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm manual interface'
      end
    end # on os
  end # on_supported_os
end

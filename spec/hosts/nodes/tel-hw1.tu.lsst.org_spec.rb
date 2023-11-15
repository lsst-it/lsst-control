# frozen_string_literal: true

require 'spec_helper'

describe 'tel-hw1.tu.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'tel-hw1.tu.lsst.org',
                       is_virtual: false,
                       virtual: 'physical',
                       dmi: {
                         'product' => {
                           'name' => 'Super Server',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'amor',
          site: 'tu',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'baremetal no bmc'

      it do
        is_expected.to contain_nfs__client__mount('/net/obs-env').with(
          share: 'obs-env',
          server: 'nfs-obsenv.tu.lsst.org',
          atboot: true,
        )
      end
    end # on os
  end # on_supported_os
end # role

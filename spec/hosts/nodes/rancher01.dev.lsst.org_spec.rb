# frozen_string_literal: true

require 'spec_helper'

describe 'rancher01.dev.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(os_facts,
                       fqdn: 'rancher01.dev.lsst.org',
                       is_virtual: true,
                       virtual: 'kvm',
                       dmi: {
                         'product' => {
                           'name' => 'KVM',
                         },
                       })
      end
      let(:node_params) do
        {
          role: 'rke',
          site: 'dev',
          cluster: 'rancher',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'vm'
      it { is_expected.to have_nm__connection_resource_count(0) }
    end # on os
  end # on_supported_os
end

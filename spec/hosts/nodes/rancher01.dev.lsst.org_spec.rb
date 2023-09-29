# frozen_string_literal: true

require 'spec_helper'

describe 'rancher01.dev.lsst.org', :sitepp do
  alma9 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '9' }).first
  # rubocop:disable Naming/VariableNumber
  on_supported_os.merge('almalinux-9-x86_64': alma9).each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    next if os =~ %r{centos-7-x86_64}

    context "on #{os}" do
      let(:facts) do
        override_facts(facts,
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

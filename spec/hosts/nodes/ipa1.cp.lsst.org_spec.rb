# frozen_string_literal: true

require 'spec_helper'

describe 'ipa1.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
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
          role: 'ipareplica',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it_behaves_like 'vm'
    end # on os
  end # on_supported_os
end

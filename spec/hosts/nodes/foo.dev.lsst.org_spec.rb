# frozen_string_literal: true

require 'spec_helper'

describe 'foo.dev.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'AS -1114S-WN10RT',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'generic',
          site: 'dev',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_package('powertop').with_ensure('absent') }
    end # on os
  end # on_supported_os
end

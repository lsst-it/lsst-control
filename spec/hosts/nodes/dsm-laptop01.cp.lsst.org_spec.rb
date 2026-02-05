# frozen_string_literal: true

require 'spec_helper'

describe 'dsm-laptop01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: false,
                            virtual: 'physical',
                            dmi: {
                              'product' => {
                                'name' => 'Latitude 5424 Rugged',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'generic',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_package('powertop').with_ensure('absent') }

      include_examples 'baremetal no bmc'
      include_context 'with nm interface'

      it { is_expected.to have_nm__connection_resource_count(3) }

      %w[
        enp0s20f0u3u5
        wlp2s0
      ].each do |i|
        context "with #{i}" do
          let(:interface) { i }

          it_behaves_like 'nm disabled interface'
        end
      end

      context 'with enp0s31f6' do
        let(:interface) { 'enp0s31f6' }

        it_behaves_like 'nm enabled interface'
        it_behaves_like 'nm ethernet interface'
        it_behaves_like 'nm dhcp interface'
      end
    end
  end
end

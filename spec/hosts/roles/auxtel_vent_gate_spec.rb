# frozen_string_literal: true

require 'spec_helper'

role = 'auxtel-vent-gate'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :sitepp do
          let(:node_params) do
            {
              role:,
              site:,
            }
          end
          let(:facts) do
            lsst_override_facts(os_facts,
                                cpuinfo: {
                                  'processor' => {
                                    'Model' => 'Raspberry Pi 4 Model B Rev 1.2',
                                  },
                                },
                                os: {
                                  'architecture' => 'aarch64',
                                })
          end

          it { is_expected.to compile.with_all_deps }

          it_behaves_like('common', os_facts:, site:)
          it_behaves_like 'docker'
          it_behaves_like('gpio', os_facts:)
          it_behaves_like('i2c', os_facts:)
          it_behaves_like 'darkmode'
          it_behaves_like 'ftdi'
          it_behaves_like 'pigpio'
          it_behaves_like 'dco'
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role

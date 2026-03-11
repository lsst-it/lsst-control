# frozen_string_literal: true

require 'spec_helper'

describe 'auxtel-vent-gates01.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:node_params) do
        {
          role: 'auxtel-vent-gate',
          site: 'cp',
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

      it_behaves_like('common', os_facts:, site: 'cp')
      it_behaves_like 'docker'
      it_behaves_like('gpio', os_facts:)
      it_behaves_like('i2c', os_facts:)
      it_behaves_like 'darkmode'
      it_behaves_like 'ftdi'
      it_behaves_like 'pigpio'
      it_behaves_like 'dco'
    end
  end
end

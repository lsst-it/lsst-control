# frozen_string_literal: true

require 'spec_helper'

role = 'ess'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
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
            override_facts(os_facts,
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

          include_examples('common', os_facts:, site:)
          include_examples 'ftdi'
          include_examples 'rubinhat'
          include_examples 'dco'
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role

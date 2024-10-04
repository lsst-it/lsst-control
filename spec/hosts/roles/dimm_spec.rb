# frozen_string_literal: true

require 'spec_helper'

role = 'dimm'

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
          let(:facts) { lsst_override_facts(os_facts) }

          it { is_expected.to compile.with_all_deps }

          include_examples('common', os_facts:, site:)
          it { is_expected.to contain_class('profile::core::yum::lsst_ts_private') }
          it { is_expected.to contain_package('ts_dimm_app-2.0-1.el8.x86_64') }
          it { is_expected.to contain_package('telnet') }

          it do
            is_expected.to contain_nfs__client__mount('/dimm').with(
              share: 'dimm',
              server: 'nfs1.cp.lsst.org',
              atboot: true
            )
          end

          it do
            is_expected.to contain_systemd__udev__rule('dimm_usb_devices.rules').with(
              rules: [
                'SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="users"',
                'SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", GROUP="users"',
                'SUBSYSTEM=="tty", ATTRS{idVendor}=="067b", ATTRS{idProduct}=="2303", GROUP="users"',
              ]
            )
          end

          %w[
            /opt/dimm
            /opt/Vimba_2_1
            /opt/astelos
            /mnt/dimm
          ].each do |d|
            it do
              is_expected.to contain_file(d).with(
                owner: 79_518,
                group: 'users',
                recurse: true
              )
            end
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role

# frozen_string_literal: true

require 'spec_helper'

role = 'dimm'

describe "#{role} role" do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: self.class.description,
        )
      end

      let(:node_params) do
        {
          role: role,
          site: site,
        }
      end

      lsst_sites.each do |site|
        describe "#{role}.#{site}.lsst.org", :site do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts
          it { is_expected.to contain_class('profile::core::yum::lsst_ts_private') }
          it { is_expected.to contain_package('ts_dimm_app-2.0-1.el8.x86_64') }
          it { is_expected.to contain_package('telnet') }

          it do
            is_expected.to contain_nfs__client__mount('/dimm').with(
              share: 'dimm',
              server: 'nfs1.cp.lsst.org',
              atboot: true,
            )
          end

          it do
            is_expected.to contain_systemd__udev__rule('dimm_usb_devices.rules').with(
              rules: [
                'SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6001", GROUP="users"',
                'SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6015", GROUP="users"',
                'SUBSYSTEM=="tty", ATTRS{idVendor}=="067b", ATTRS{idProduct}=="2303", GROUP="users"',
              ],
            )
          end
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role

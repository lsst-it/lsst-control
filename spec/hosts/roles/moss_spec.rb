# frozen_string_literal: true

require 'spec_helper'

role = 'moss'

describe "#{role} role" do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node_params) do
        {
          role:,
          site:,
        }
      end

      lsst_sites.each do |site|
        fqdn = "#{role}.#{site}.lsst.org"
        override_facts(os_facts, fqdn:, networking: { fqdn => fqdn })

        describe fqdn, :sitepp do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          it_behaves_like('common', os_facts:, site:)
          it_behaves_like 'add_usb'
          it_behaves_like 'darkmode'
          it_behaves_like 'ftdi'
          it_behaves_like 'dco'
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role

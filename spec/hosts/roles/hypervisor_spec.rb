# frozen_string_literal: true

require 'spec_helper'

role = 'hypervisor'

describe "#{role} role" do
  alma9 = FacterDB.get_facts({ operatingsystem: 'AlmaLinux', operatingsystemmajrelease: '9' }).first
  # rubocop:disable Naming/VariableNumber
  on_supported_os.merge('almalinux-9-x86_64': alma9).each do |os, facts|
    # rubocop:enable Naming/VariableNumber
    context "on #{os}" do
      let(:facts) { facts }
      let(:node_params) do
        {
          role: role,
          site: site,
        }
      end

      lsst_sites.each do |site|
        fqdn = "#{role}.#{site}.lsst.org"
        override_facts(facts, fqdn: fqdn, networking: { fqdn => fqdn })

        describe fqdn, :sitepp do
          let(:site) { site }

          it { is_expected.to compile.with_all_deps }

          include_examples 'common', facts: facts

          %w[
            libguestfs
            qemu-guest-agent
            qemu-kvm-tools
            virt-install
            virt-manager
            virt-top
            virt-viewer
            virt-what
            xauth
          ].each do |pkg|
            it { is_expected.to contain_package(pkg) }
          end
        end # host
      end # lsst_sites
    end
  end
end

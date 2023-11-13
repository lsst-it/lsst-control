# frozen_string_literal: true

require 'spec_helper'

role = 'hypervisor'

describe "#{role} role" do
  on_supported_os.each do |os, facts|
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

          it { is_expected.to contain_class('tuned').with_active_profile('virtual-host') }

          if facts[:os]['release']['major'] == '9'
            it do
              is_expected.to contain_service('virtproxyd').with(
                enable: true,
                tag: 'libvirt-libvirtd-conf',
              )
            end

            %w[
              virtqemud.socket
              virtqemud-ro.socket
              virtqemud-admin.socket
              virtnetworkd.socket
              virtnetworkd-ro.socket
              virtnetworkd-admin.socket
              virtnodedevd.socket
              virtnodedevd-ro.socket
              virtnodedevd-admin.socket
              virtnwfilterd.socket
              virtnwfilterd-ro.socket
              virtnwfilterd-admin.socket
              virtsecretd.socket
              virtsecretd-ro.socket
              virtsecretd-admin.socket
              virtstoraged.socket
              virtstoraged-ro.socket
              virtstoraged-admin.socket
              virtinterfaced.socket
              virtinterfaced-ro.socket
              virtinterfaced-admin.socket
            ].each do |svc|
              it do
                is_expected.to contain_service(svc).with(
                  ensure: 'running',
                  enable: true,
                  tag: 'libvirt-libvirtd-conf',
                )
              end
            end
          end
        end # host
      end # lsst_sites
    end
  end
end

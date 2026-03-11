# frozen_string_literal: true

require 'spec_helper'

role = 'niagara'

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
          let(:facts) { lsst_override_facts(os_facts) }

          it { is_expected.to compile.with_all_deps }

          it_behaves_like('common', os_facts:, site:)

          it { is_expected.to contain_sudo__conf('niagara_sudoers').with_content('%niagara ALL=(ALL) NOPASSWD: /usr/bin/niagaradctl') }

          it { is_expected.to contain_class('restic') }

          it {
            is_expected.to contain_restic__repository('awsrepo').with(
              backup_path: ['/etc/mosquitto', '/opt/Niagara'],
              backup_timer: '*-*-* 09:00:00',
              enable_forget: true,
              forget_timer: 'Mon..Sun 23:00:00',
              forget_flags: '--keep-last 20',
            )
          }
        end # host
      end # lsst_sites
    end # on os
  end # on_supported_os
end # role

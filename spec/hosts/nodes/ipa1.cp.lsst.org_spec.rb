# frozen_string_literal: true

require 'spec_helper'

describe 'ipa1.cp.lsst.org', :sitepp do
  on_supported_os.each do |os, os_facts|
    next unless os =~ %r{almalinux-9-x86_64}

    context "on #{os}" do
      let(:facts) do
        lsst_override_facts(os_facts,
                            is_virtual: true,
                            virtual: 'kvm',
                            dmi: {
                              'product' => {
                                'name' => 'KVM',
                              },
                            })
      end
      let(:node_params) do
        {
          role: 'ipareplica',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'vm'
      include_examples 'restic common'

      it do
        is_expected.to contain_restic__repository('ipa').with(
          backup_path: %w[
            /var/lib/ipa/backup
          ],
          backup_pre_cmd: 'mkdir /var/lib/ipa/backup;/sbin/ipa-backup',
          backup_post_cmd: 'rm -rf /var/lib/ipa/backup',
          backup_timer: '*-*-* 9:23:00',
          enable_forget: true,
          forget_timer: '*-*-* 10:23:00',
          forget_flags: '--keep-last 90'
        )
      end
    end # on os
  end # on_supported_os
end

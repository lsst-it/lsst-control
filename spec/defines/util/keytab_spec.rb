# frozen_string_literal: true

require 'spec_helper'

describe 'profile::util::keytab' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'foo' }
      let(:params) { { 'uid' => 123, 'keytab_base64' => sensitive('YmFy') } }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.not_to contain_file('/home/foo') }

      it do
        is_expected.to contain_file('/home/foo/.keytab').with(
          ensure: 'absent',
        )
      end

      it do
        is_expected.to contain_file('/var/lib/keytab').with(
          ensure: 'directory',
          owner: 'root',
          group: 'root',
          mode: '0700',
          purge: true,
          recurse: true,
        )
      end

      it do
        is_expected.to contain_file('/var/lib/keytab/foo').with(
          ensure: 'file',
          owner: 'root',
          group: 'root',
          mode: '0400',
          show_diff: false,
          content: 'bar',
        )
      end

      it do
        is_expected.to contain_cron('k5start_root').with(
          command: '/usr/bin/k5start -f /var/lib/keytab/foo -U -o 123 -k /tmp/krb5cc_123 -H 60 -F > /dev/null 2>&1',
        )
      end

      it { is_expected.to contain_cron('k5start_root').that_requires(['File[/var/lib/keytab/foo]']) }
    end
  end
end

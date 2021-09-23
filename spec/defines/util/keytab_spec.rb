# frozen_string_literal: true

require 'spec_helper'

describe 'profile::util::keytab' do
  let(:title) { 'foo' }
  let(:params) { { 'uid' => 123, 'keytab_base64' => 'YmFy' } }

  it { is_expected.to compile.with_all_deps }

  it do
    is_expected.to contain_file('/home/foo').with(
      ensure: 'directory',
      owner: 'foo',
      group: 'foo',
      mode: '0700',
    )
  end

  it do
    is_expected.to contain_file('/home/foo/.keytab').with(
      ensure: 'file',
      owner: 'foo',
      group: 'foo',
      mode: '0400',
      content: 'bar',
    )
  end

  it do
    is_expected.to contain_cron('k5start_root').with(
      command: '/usr/bin/k5start -f /home/foo/.keytab -U -o 123 -k /tmp/krb5cc_123 -H 60 > /dev/null 2>&1',
    )
  end

  it { is_expected.to contain_cron('k5start_root').that_requires(['File[/home/foo/.keytab]']) }
end

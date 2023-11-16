# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ts::love' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it do
        is_expected.to contain_vcsrepo('/home/dco/LOVE-integration-tools').with(
          ensure: 'present',
          provider: 'git',
          source: 'https://github.com/lsst-ts/LOVE-integration-tools.git',
          keep_local_changes: true,
          user: 'dco',
          owner: 'dco',
          group: 'dco',
        )
      end
    end
  end
end

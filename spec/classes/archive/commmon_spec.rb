# frozen_string_literal: true

require 'spec_helper'

describe 'profile::archive::common' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:pre_condition) do
        <<~PP
          # change service unit name from sssd.service to sssd
          class { 'sssd': service_names => ['sssd'] }
        PP
      end

      it { is_expected.to compile.with_all_deps }

      include_examples 'archiver'

      %w[
        git
        cmake
        gcc-c++
      ].each do |p|
        it { is_expected.to contain_package(p) }
      end

      it { is_expected.to contain_accounts__user('arc').with_uid('61000') }
      it { is_expected.to contain_accounts__user('atadbot').with_uid('61002') }

      it do
        is_expected.to contain_sudo__conf('comcam_archive_cmd')
          .with_content('%comcam-archive-sudo ALL=(arc,atadbot) NOPASSWD: ALL')
      end
    end
  end
end

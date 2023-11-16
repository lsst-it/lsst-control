# frozen_string_literal: true

require 'spec_helper'

describe 'profile::archive::data' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_file('/data').with_ensure('directory') }
      it { is_expected.to contain_file('/data/lsstdata').with_ensure('directory') }
      it { is_expected.to contain_file('/data/repo').with_ensure('directory') }
      it { is_expected.to contain_file('/data/staging').with_ensure('directory') }
      it { is_expected.to contain_file('/repo').with_ensure('directory') }

      it { is_expected.not_to contain_file('/data/repo/LATISS') }
      it { is_expected.not_to contain_file('/data/repo/LSSTComCam') }
    end
  end
end

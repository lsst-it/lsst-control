# frozen_string_literal: true

require 'spec_helper'

describe 'profile::archive::data::comcam' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it { is_expected.not_to contain_file('/data/repo/LATISS') }
      it { is_expected.to contain_file('/data/repo/LSSTComCam').with_mode('0777') }
      it { is_expected.to contain_file('/data/repo/LSSTComCam/u').with_mode('1777') }
    end
  end
end

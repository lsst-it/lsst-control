# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::perccli' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_yumrepo('dell') }
      it { is_expected.to contain_package('perccli').that_requires(['Yumrepo[dell]']) }
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe 'profile::ts::rpi' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to compile.with_all_deps }

      %w[
        docker-1.13*.aarch64
        docker-client
        docker-client-latest
        docker-common
        docker-latest
        docker-latest-logrotate
        docker-logrotate
        docker-engine
      ].each do |pkg|
        it { is_expected.to contain_package(pkg).with_ensure('absent') }
      end
    end
  end
end

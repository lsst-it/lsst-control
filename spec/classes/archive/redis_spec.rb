# frozen_string_literal: true

require 'spec_helper'

describe 'profile::archive::redis' do
  let(:node_params) { { org: 'lsst' } }

  it { is_expected.to compile.with_all_deps }

  it { is_expected.to contain_class('redis') }
  it { is_expected.to contain_file('/etc/profile.d/rh-redis5.sh') }
end

# frozen_string_literal: true

require 'spec_helper'

describe 'profile::archive::data' do
  let(:node_params) { { org: 'lsst' } }

  it { is_expected.to compile.with_all_deps }

  it { is_expected.to contain_file('/data').with_ensure('directory') }
  it { is_expected.to contain_file('/data/lsstdata').with_ensure('directory') }
  it { is_expected.to contain_file('/data/repo').with_ensure('directory') }
  it { is_expected.to contain_file('/data/staging').with_ensure('directory') }
  it { is_expected.to contain_file('/repo').with_ensure('directory') }

  it { is_expected.not_to contain_file('/data/repo/LATISS') }
  it { is_expected.not_to contain_file('/data/repo/LSSTComCam') }
end
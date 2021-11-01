# frozen_string_literal: true

require 'spec_helper'

describe 'profile::archive::data::comcam' do
  let(:node_params) { { org: 'lsst' } }

  it { is_expected.to compile.with_all_deps }

  it { is_expected.not_to contain_file('/data/repo/LATISS') }
  it { is_expected.to contain_file('/data/repo/LSSTComCam') }
end

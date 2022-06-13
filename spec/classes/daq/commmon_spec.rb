# frozen_string_literal: true

require 'spec_helper'

describe 'profile::daq::common' do
  %w[
    /srv
    /srv/nfs
    /srv/nfs/lsst-daq
    /srv/nfs/lsst-daq/daq-sdk
  ].each do |f|
    it do
      is_expected.to contain_file(f).with(
        ensure: 'directory',
        owner: 'root',
        group: 'root',
        mode: '0755',
      )
    end
  end

  it do
    is_expected.to contain_mount('/srv/nfs/lsst-daq/daq-sdk').with(
      device: '/opt/lsst/daq-sdk',
      fstype: 'none',
      options: 'defaults,bind',
    )
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::docker' do
  let(:node_params) { { org: 'lsst' } }

  it { is_expected.to compile.with_all_deps }

  it do
    is_expected.to contain_class('docker').with(
      overlay2_override_kernel_check: true,
      socket_group: 70_014,
      socket_override: true,
      storage_driver: 'overlay2',
      version: '19.03.15',
    )
  end

  it { is_expected.to contain_class('yum::plugin::versionlock') }
  it { is_expected.to have_yum__versionlock_resource_count(2) }
  it { is_expected.to contain_class('docker::networks') }

  context 'when site tu' do
    let(:node_params) do
      super().merge(
        site: 'tu',
      )
    end

    it { is_expected.to contain_class('docker').with(version: '20.10.9') }
  end
end

# frozen_string_literal: true

require 'spec_helper'

shared_examples 'generic ccs-dc' do
  include_examples 'lsst-daq client'
end

describe 'ccs-dc role' do
  let(:node_params) do
    {
      role: 'ccs-dc',
      cluster: 'comcam-ccs',
    }
  end

  let(:facts) { { fqdn: self.class.description } }

  describe 'comcam-dc01.cp.lsst.org', :site, :common do
    let(:node_params) do
      super().merge(
        site: 'cp',
      )
    end

    it { is_expected.to compile.with_all_deps }

    include_examples 'generic ccs-dc'
  end # host

  describe 'comcam-dc01.tu.lsst.org', :site, :common do
    let(:node_params) do
      super().merge(
        site: 'tu',
      )
    end

    it { is_expected.to compile.with_all_deps }

    include_examples 'generic ccs-dc'
  end # host
end # role

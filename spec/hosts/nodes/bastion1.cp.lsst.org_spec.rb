# frozen_string_literal: true

require 'spec_helper'

#
# note that this hosts has interfaces with an mtu of 9000
#
describe 'bastion1.cp.lsst.org', :site do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          fqdn: 'bastion1.cp.lsst.org',
        )
      end

      let(:node_params) do
        {
          role: 'bastion',
          site: 'cp',
        }
      end

      it { is_expected.to compile.with_all_deps }
    end # on os
  end # on_supported_os
end

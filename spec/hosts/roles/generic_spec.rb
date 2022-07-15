# frozen_string_literal: true

require 'spec_helper'

describe 'generic role' do
  let(:node_params) do
    {
      role: 'generic',
    }
  end

  let(:facts) { { fqdn: self.class.description } }

  lsst_sites.each do |site|
    describe "generic.#{site}.lsst.org", :site, :common do
      let(:node_params) do
        super().merge(
          site: site,
        )
      end

      it { is_expected.to compile.with_all_deps }
    end # host
  end # lsst_sites
end # role

# frozen_string_literal: true

require 'spec_helper'

describe 'test1.dev.lsst.org' do
  describe 'dtn role' do
    lsst_sites.each do |site|
      context "with site #{site}", :site, :common do
        let(:node_params) do
          {
            site: site,
            role: 'dtn',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('profile::core::common') }
        it { is_expected.to contain_class('profile::core::dtn') }

        it do
          expect(catalogue.resource('class', 'ssh')[:server_options]).to include(
            'Port' => [22, 2712],
          )
        end
      end
    end # site
  end # role
end

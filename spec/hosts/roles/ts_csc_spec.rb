# frozen_string_literal: true

require 'spec_helper'

describe 'test1.dev.lsst.org' do
  describe 'ts-csc role' do
    lsst_sites.each do |site|
      context "with site #{site}", :site, :common do
        let(:node_params) do
          {
            site: site,
            role: 'ts-csc',
            cluster: 'trewa',
          }
        end

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('docker::networks') }
      end
    end # site
  end # role
end

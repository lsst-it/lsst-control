# frozen_string_literal: true

require 'spec_helper'

describe 'test1.dev.lsst.org', :site do
  describe 'icinga-master role' do
    lsst_sites.each do |site|
      context "with site #{site}" do
        let(:node_params) do
          {
            site: site,
            role: 'icinga-master',
            ipa_force_join: false, # easy_ipa
          }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_nginx__resource__server('icingaweb2').with(
            ssl_cert: %r{fullchain.pem$},
          )
        end
      end
    end # site
  end # role
end

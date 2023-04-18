# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::perfsonar' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:fqdn) { facts[:fqdn] }
      let(:le_root) { "/etc/letsencrypt/live/#{fqdn}" }
      let(:perfsonar_version) { '4.4.0' }

      it { is_expected.to compile.with_all_deps }

      include_examples 'generic perfsonar', facts: facts

      context 'with version param' do
        context 'with 5.0.0' do
          let(:perfsonar_version) { '5.0.0' }
          let(:params) do
            {
              version: perfsonar_version,
            }
          end

          include_examples 'generic perfsonar', facts: facts
        end
      end
    end
  end
end

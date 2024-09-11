# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::perfsonar' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:fqdn) { facts[:networking]['fqdn'] }
      let(:le_root) { "/etc/letsencrypt/live/#{fqdn}" }
      let(:perfsonar_version) { '4.4.0' }

      it { is_expected.to compile.with_all_deps }

      include_examples 'generic perfsonar', os_facts: os_facts

      context 'with version param' do
        context 'with 5.0.0' do
          let(:perfsonar_version) { '5.0.0' }
          let(:params) do
            {
              version: perfsonar_version,
            }
          end

          include_examples 'generic perfsonar', os_facts: os_facts
        end
      end
    end
  end
end

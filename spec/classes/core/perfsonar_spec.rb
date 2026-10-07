# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::perfsonar' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:le_root) { "/etc/letsencrypt/live/#{os_facts[:networking]['fqdn']}" }
      let(:perfsonar_version) { '5.2.5' }

      it { is_expected.to compile.with_all_deps }

      it_behaves_like('generic perfsonar', os_facts:)

      context 'with version param' do
        context 'with 5.1.4' do
          let(:perfsonar_version) { '5.2.5' }
          let(:params) do
            {
              version: perfsonar_version,
            }
          end

          it_behaves_like 'generic perfsonar', os_facts:
        end
      end
    end
  end
end

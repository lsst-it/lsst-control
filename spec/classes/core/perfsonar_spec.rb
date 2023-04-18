# frozen_string_literal: true

require 'spec_helper'

describe 'profile::core::perfsonar' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:fqdn) { facts[:fqdn] }
      let(:le_root) { "/etc/letsencrypt/live/#{fqdn}" }

      it { is_expected.to compile.with_all_deps }

      include_examples 'generic perfsonar', facts: facts
    end
  end
end
